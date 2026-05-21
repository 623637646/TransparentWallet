use crate::managers::{
    db::{RepositoryError, Repository},
    localization::{self, Language},
};
use fluent_langneg::{NegotiationStrategy, negotiate_languages};
use fluent_templates::{Loader, static_loader};
use rx_rust::{
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
    selected_language: BehaviorSubject<'static, localization::Model, Infallible>,
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
}

impl<R> LocalizationManager<R>
where
    R: Repository,
{
    pub(crate) async fn new(repository: R) -> Result<Self, RepositoryError> {
        let model = repository.read::<localization::Entity>().await?;
        let selected_language = BehaviorSubject::new(model);

        // Create effective language.
        let system_language = BehaviorSubject::new(Vec::new());
        let system_language_cloned = system_language.clone();
        let effective_language = selected_language
            .clone()
            .map(|model| model.language)
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

        Ok(Self {
            repository,
            selected_language,
            system_language,
            effective_language,
        })
    }

    pub fn selected_language(
        &self,
    ) -> impl Observable<'static, 'static, Option<Language>, Infallible> + Clone {
        self.selected_language.clone().map(|model| model.language)
    }

    pub async fn set_selected_language(
        &self,
        selected_language: Option<Language>,
    ) -> Result<(), RepositoryError> {
        let mut model = self.selected_language.value();
        model.language = selected_language;
        self.repository
            .write::<localization::Entity>(model.clone())
            .await
            .inspect_err(|e| {
                log::error!("write localization error: {}", e);
            })?;
        self.selected_language.clone().on_next(model);
        Ok(())
    }

    pub fn set_supported_system_languages(&mut self, languages: Vec<String>) {
        self.system_language.on_next(
            languages
                .into_iter()
                .filter_map(|s| s.parse().ok())
                .collect(),
        );
    }

    pub fn lookup(
        &self,
        text_id: String,
    ) -> impl Observable<'static, 'static, String, LocalizationError> {
        self.lookup_impl(text_id, None)
    }

    pub fn lookup_with_args(
        &self,
        text_id: String,
        args: HashMap<String, String>,
    ) -> impl Observable<'static, 'static, String, LocalizationError> {
        self.lookup_impl(text_id, Some(args))
    }

    fn lookup_impl(
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
