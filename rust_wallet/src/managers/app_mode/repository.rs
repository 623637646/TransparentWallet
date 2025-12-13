use crate::{
    error::WalletError,
    managers::{app_mode, db::DBManager},
};
use sea_orm::{ActiveModelTrait, ActiveValue::Set, EntityTrait, IntoActiveModel};

pub(crate) trait AppModeRepository {
    fn get_app_mode(
        &self,
    ) -> impl std::future::Future<Output = Result<app_mode::Model, WalletError>>
    + std::marker::Send
    + 'static;

    fn set_app_mode(
        &self,
        app_mode: app_mode::Model,
    ) -> impl std::future::Future<Output = Result<(), WalletError>> + std::marker::Send + 'static;
}

impl AppModeRepository for DBManager {
    fn get_app_mode(
        &self,
    ) -> impl std::future::Future<Output = Result<app_mode::Model, WalletError>>
    + std::marker::Send
    + 'static {
        let this = self.clone();
        async move {
            let connection = this.get_connection();
            match app_mode::Entity::find().one(&connection).await? {
                Some(app_mode) => Ok(app_mode),
                None => {
                    let app_mode = app_mode::ActiveModel {
                        app_mode: Set(app_mode::AppMode::Init),
                        ..Default::default()
                    };
                    let app_mode = app_mode.insert(&connection).await?;
                    Ok(app_mode)
                }
            }
        }
    }

    fn set_app_mode(
        &self,
        app_mode: app_mode::Model,
    ) -> impl std::future::Future<Output = Result<(), WalletError>> + std::marker::Send + 'static
    {
        let this = self.clone();
        async move {
            let connection = this.get_connection();
            let active_model = app_mode.into_active_model();
            let active_model = active_model.reset_all(); // TODO: need this?
            active_model.update(&connection).await?;
            Ok(())
        }
    }
}
