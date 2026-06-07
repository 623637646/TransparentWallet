use crate::managers::{
    app_mode::{self, AppMode},
    db::{Repository, RepositoryError},
};
use rx_rust::{
    observable::{Observable, observable_ext::ObservableExt},
    observer::Observer,
    subject::behavior_subject::BehaviorSubject,
};
use std::convert::Infallible;

pub struct AppModeManager<R> {
    repository: R,
    app_mode: BehaviorSubject<'static, app_mode::Model, Infallible>,
}

impl<R> AppModeManager<R>
where
    R: Repository,
{
    pub(crate) async fn new(repository: R) -> Result<Self, RepositoryError> {
        let model = repository.read::<app_mode::Entity>().await?;
        let app_mode = BehaviorSubject::new(model);
        Ok(Self {
            repository,
            app_mode,
        })
    }

    pub fn app_mode(&self) -> impl Observable<'static, 'static, AppMode, Infallible> + Clone {
        self.app_mode.clone().map(|model| model.app_mode)
    }

    pub async fn set_app_mode(&self, app_mode: AppMode) -> Result<(), RepositoryError> {
        let mut model = self.app_mode.value();
        model.app_mode = app_mode;
        self.repository
            .write::<app_mode::Entity>(model.clone())
            .await?;
        self.app_mode.clone().on_next(model);
        Ok(())
    }
}
