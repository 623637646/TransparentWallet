use crate::{
    error::WalletError,
    managers::{db::DBManager, localization},
};
use sea_orm::{ActiveModelTrait, ActiveValue::Set, EntityTrait, IntoActiveModel};

pub(crate) trait LocalizationRepository {
    fn get_localization(
        &self,
    ) -> impl std::future::Future<Output = Result<localization::Model, WalletError>>
    + std::marker::Send
    + 'static;

    fn set_localization(
        &self,
        localization: localization::Model,
    ) -> impl std::future::Future<Output = Result<(), WalletError>> + std::marker::Send + 'static;
}

impl LocalizationRepository for DBManager {
    fn get_localization(
        &self,
    ) -> impl std::future::Future<Output = Result<localization::Model, WalletError>>
    + std::marker::Send
    + 'static {
        let this = self.clone();
        async move {
            let connection = this.get_connection();
            match localization::Entity::find().one(&connection).await? {
                Some(localization) => Ok(localization),
                None => {
                    let localization = localization::ActiveModel {
                        language: Set(None),
                        ..Default::default()
                    };
                    let localization = localization.insert(&connection).await?;
                    Ok(localization)
                }
            }
        }
    }

    fn set_localization(
        &self,
        localization: localization::Model,
    ) -> impl std::future::Future<Output = Result<(), WalletError>> + std::marker::Send + 'static
    {
        let this = self.clone();
        async move {
            let connection = this.get_connection();
            let active_model = localization.into_active_model();
            let active_model = active_model.reset_all();
            active_model.update(&connection).await?;
            Ok(())
        }
    }
}
