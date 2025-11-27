use crate::managers::{app_settings, db::DBManager};
use sea_orm::{ActiveModelTrait, ActiveValue::Set, EntityTrait, IntoActiveModel};

pub(crate) trait AppSettingsRepository {
    fn get_app_settings(
        &self,
    ) -> impl std::future::Future<Output = Result<app_settings::Model, anyhow::Error>>
           + std::marker::Send
           + 'static;

    fn set_app_settings(
        &self,
        app_settings: app_settings::Model,
    ) -> impl std::future::Future<Output = Result<(), anyhow::Error>> + std::marker::Send + 'static;
}

impl AppSettingsRepository for DBManager {
    fn get_app_settings(
        &self,
    ) -> impl std::future::Future<Output = Result<app_settings::Model, anyhow::Error>>
           + std::marker::Send
           + 'static {
        let this = self.clone();
        async move {
            let connection = this.get_connection();
            match app_settings::Entity::find().one(&connection).await? {
                Some(app_settings) => Ok(app_settings),
                None => {
                    let app_settings = app_settings::ActiveModel {
                        app_mode: Set(app_settings::AppMode::Init),
                        language: Set(app_settings::Language::English),
                        ..Default::default()
                    };
                    let app_settings = app_settings.insert(&connection).await?;
                    Ok(app_settings)
                }
            }
        }
    }

    fn set_app_settings(
        &self,
        app_settings: app_settings::Model,
    ) -> impl std::future::Future<Output = Result<(), anyhow::Error>> + std::marker::Send + 'static
    {
        let this = self.clone();
        async move {
            let connection = this.get_connection();
            let active_model = app_settings.into_active_model();
            let active_model = active_model.reset_all();
            active_model.update(&connection).await?;
            Ok(())
        }
    }
}
