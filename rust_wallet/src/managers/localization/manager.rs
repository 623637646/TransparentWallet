use crate::{
    error::WalletError,
    managers::localization::{Language, repository::LocalizationRepository},
};
use fluent_langneg::{NegotiationStrategy, negotiate_languages};
use fluent_templates::{Loader, static_loader};
use futures::FutureExt;
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

static_loader! {
    static LOCALES = {
        locales: "locales",
        fallback_language: "en",
    };
}

pub struct LocalizationManager {
    // User selected language. None means use selected system language.
    pub selected_language: BehaviorSubject<'static, Option<Language>, Infallible>,
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

impl LocalizationManager {
    pub(crate) async fn new(
        repository: impl LocalizationRepository + Send + Sync + 'static,
    ) -> Result<Self, WalletError> {
        let app_mode = repository.get_localization().await?;
        let selected_language = BehaviorSubject::new(app_mode.language.clone());

        // Subscribe to selected language changes and save to repository.
        let sub = selected_language.clone().skip(1).subscribe_with_callback(
            move |value| {
                let mut app_mode = app_mode.clone();
                app_mode.language = value;
                tokio::spawn(repository.set_localization(app_mode).map(|res| {
                    if let Err(e) = res {
                        log::error!("set_localization error: {}", e);
                    }
                }));
            },
            |_| unreachable!(),
        );

        // Create effective language.
        let system_language = BehaviorSubject::new(Vec::new());
        let system_language_cloned = system_language.clone();
        let effective_language = selected_language
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

        Ok(Self {
            selected_language,
            system_language,
            effective_language,
            _subscription: sub,
        })
    }

    pub fn lookup(
        &self,
        text_id: String,
    ) -> impl Observable<'static, 'static, String, WalletError> {
        self.lookup_impl(text_id, None)
    }

    pub fn lookup_with_args(
        &self,
        text_id: String,
        args: HashMap<String, String>,
    ) -> impl Observable<'static, 'static, String, WalletError> {
        self.lookup_impl(text_id, Some(args))
    }

    fn lookup_impl(
        &self,
        text_id: String,
        args: Option<HashMap<String, String>>,
    ) -> impl Observable<'static, 'static, String, WalletError> {
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
                    None => Throw::new(WalletError::LocalizationTextNotFound(text_id.clone()))
                        .map_infallible_to_value()
                        .into_boxed(),
                }
            })
    }

    pub fn update_system_language(&mut self, languages: Vec<String>) {
        self.system_language.on_next(
            languages
                .into_iter()
                .filter_map(|s| s.parse().ok())
                .collect(),
        );
    }
}

impl From<&Language> for fluent_langneg::LanguageIdentifier {
    fn from(value: &Language) -> Self {
        value.to_string().parse().unwrap()
    }
}
