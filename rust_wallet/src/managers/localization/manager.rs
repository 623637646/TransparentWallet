use crate::managers::{
    db::{Repository, RepositoryError},
    localization::{self, Language},
};
use fluent_langneg::{NegotiationStrategy, negotiate_languages};
use fluent_templates::{Loader, static_loader};
use rx_rust::{
    disposable::subscription::Subscription,
    observable::{
        Observable, cloneable_boxed_observable::CloneableBoxedObservable,
        observable_ext::ObservableExt,
    },
    observer::Observer,
    operators::creating::{just::Just, throw::Throw},
    subject::behavior_subject::BehaviorSubject,
};
use std::{collections::HashMap, convert::Infallible};
use thiserror::Error;

static_loader! {
    static LOCALES = {
        locales: "locales",
        fallback_language: "en",
    };
}

#[derive(Error, Debug)]
pub enum LocalizationError {
    #[error("Localization text not found for id: {0}")]
    LocalizationTextNotFound(String),
}

pub struct LocalizationManager<R> {
    repository: R,
    // User selected language. None means use selected system language.
    language: BehaviorSubject<'static, Option<Language>, Infallible>,
    // Languages from system settings.
    system_language: BehaviorSubject<'static, Vec<fluent_langneg::LanguageIdentifier>, Infallible>,
    // Effective language used for lookup.
    effective_language: CloneableBoxedObservable<
        'static,
        'static,
        'static,
        fluent_templates::LanguageIdentifier,
        Infallible,
    >,
    _subscription: Subscription<'static>,
}

impl<R> LocalizationManager<R>
where
    R: Repository,
{
    pub(crate) async fn new(repository: R) -> Result<Self, RepositoryError> {
        let model = repository.read_unique::<localization::Entity>().await?;
        let language = BehaviorSubject::new(model.language);

        // Create effective language.
        let system_language = BehaviorSubject::new(Vec::new());
        let system_language_cloned = system_language.clone();
        let effective_language = language
            .clone()
            .flat_map(move |language| match language {
                Some(language) => Just::new((&language).into()).into_boxed(),
                None => system_language_cloned
                    .clone()
                    .map(|languages| {
                        let requested: Vec<fluent_langneg::LanguageIdentifier> = languages;
                        let available: Vec<fluent_langneg::LanguageIdentifier> = LOCALES
                            .locales()
                            .filter_map(|l| l.to_string().parse().ok())
                            .collect();
                        let default: fluent_langneg::LanguageIdentifier =
                            Language::English.to_string().parse().unwrap();

                        let supported = negotiate_languages(
                            &requested,
                            &available,
                            Some(&default),
                            NegotiationStrategy::Lookup,
                        );
                        supported.first().cloned().cloned().unwrap_or(default)
                    })
                    .into_boxed(),
            })
            .map(|language| language.to_string().parse().unwrap())
            .share_replay(Some(1)) // Cache the last value
            .into_cloneable_boxed();

        let _subscription = repository.reset_default_when_reset_notify(language.clone());

        Ok(Self {
            repository,
            language,
            system_language,
            effective_language,
            _subscription,
        })
    }

    pub fn language(
        &self,
    ) -> impl Observable<'static, 'static, Option<Language>, Infallible> + Clone {
        self.language.clone()
    }

    pub async fn set_language(&self, language: Option<Language>) -> Result<(), RepositoryError> {
        let mut model = localization::Model::default();
        model.language = language.clone();
        self.repository
            .write_unique::<localization::Entity>(model)
            .await?;
        self.language.clone().on_next(language);
        Ok(())
    }

    pub fn set_supported_system_languages(&self, languages: Vec<String>) {
        self.system_language.clone().on_next(
            languages
                .into_iter()
                .filter_map(|s| s.parse().ok())
                .collect(),
        );
    }

    pub fn lookup(
        &self,
        text_id: String,
        args: Option<HashMap<String, String>>,
    ) -> impl Observable<'static, 'static, String, LocalizationError> {
        self.effective_language
            .clone()
            .map_infallible_to_error()
            .flat_map(move |language| {
                let result = if let Some(args) = &args {
                    let args = args
                        .iter()
                        .map(|(k, v)| (k.clone().into(), v.clone().into()))
                        .collect();
                    LOCALES.try_lookup_with_args(&language, &text_id, &args)
                } else {
                    LOCALES.try_lookup(&language, &text_id)
                };
                match result {
                    Some(text) => Just::new(text).map_infallible_to_error().into_boxed(),
                    None => {
                        log::warn!("Localization text not found: {}", text_id);
                        Throw::new(LocalizationError::LocalizationTextNotFound(text_id.clone()))
                            .map_infallible_to_value()
                            .into_boxed()
                    }
                }
            })
    }
}

impl From<&Language> for fluent_langneg::LanguageIdentifier {
    fn from(value: &Language) -> Self {
        value.to_string().parse().unwrap()
    }
}
