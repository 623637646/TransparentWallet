use sea_orm::entity::prelude::*;

#[sea_orm::model]
#[derive(Debug, Clone, PartialEq, Eq, DeriveEntityModel, Default)]
#[sea_orm(table_name = "pin")]
pub struct Model {
    #[sea_orm(primary_key)]
    id: i32,
    pub(crate) secret_context_data: Option<Vec<u8>>, // None means that the user has not set a PIN yet
}

impl ActiveModelBehavior for ActiveModel {}
