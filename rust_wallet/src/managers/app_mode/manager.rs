use crate::managers::{
    app_mode::{self, AppMode},
    db::{Repository, RepositoryError},
};
use rx_rust::{
    disposable::subscription::Subscription, observable::Observable, observer::Observer,
    subject::behavior_subject::BehaviorSubject,
};
use std::convert::Infallible;

pub struct AppModeManager<R> {
    repository: R,
    app_mode: BehaviorSubject<'static, AppMode, Infallible>,
    _subscription: Subscription<'static>,
}

impl<R> AppModeManager<R>
where
    R: Repository,
{
    pub(crate) async fn new(repository: R) -> Result<Self, RepositoryError> {
        let model = repository.read_unique::<app_mode::Entity>().await?;
        let app_mode = BehaviorSubject::new(model.app_mode);
        let _subscription = repository.reset_default_when_reset_notify(app_mode.clone());
        Ok(Self {
            repository,
            app_mode,
            _subscription,
        })
    }

    pub fn app_mode(&self) -> impl Observable<'static, 'static, AppMode, Infallible> + Clone {
        self.app_mode.clone()
    }

    pub async fn set_app_mode(&self, app_mode: AppMode) -> Result<(), RepositoryError> {
        let mut model = app_mode::Model::default();
        model.app_mode = app_mode.clone();
        self.repository
            .write_unique::<app_mode::Entity>(model)
            .await?;
        self.app_mode.clone().on_next(app_mode);
        Ok(())
    }
}
