use sea_orm::entity::prelude::*;
use strum_macros::Display;

#[sea_orm::model]
#[derive(Debug, Clone, PartialEq, Eq, DeriveEntityModel)]
#[sea_orm(table_name = "localization")]
pub struct Model {
    #[sea_orm(primary_key)]
    id: i32,
    pub(crate) language: Option<Language>,
}

impl ActiveModelBehavior for ActiveModel {}

#[derive(Debug, Clone, PartialEq, Eq, EnumIter, DeriveActiveEnum, Display)]
#[sea_orm(
    rs_type = "String",
    db_type = "String(StringLen::None)",
    rename_all = "camelCase"
)]
pub enum Language {
    #[strum(serialize = "en-US")]
    English,
    #[strum(serialize = "zh-CN")]
    Chinese,
}
