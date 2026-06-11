use log::LevelFilter;
use log::{Level, Metadata, Record};
use rx_rust::observable::Observable;
use rx_rust::observer::Observer;
use rx_rust::subject::publish_subject::PublishSubject;
use std::convert::Infallible;
use std::ops::Deref;
use std::sync::LazyLock;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum LogLevel {
    Trace,
    Debug,
    Info,
    Warn,
    Error,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct LogEntry {
    pub time_millis: u128,
    pub level: LogLevel,
    pub tag: String,
    pub msg: String,
}

static APP_LOGGER: LazyLock<AppLogger> = LazyLock::new(|| AppLogger(PublishSubject::new()));

struct AppLogger(PublishSubject<'static, LogEntry, Infallible>);

impl log::Log for AppLogger {
    fn enabled(&self, _metadata: &Metadata) -> bool {
        true
    }

    fn log(&self, record: &Record) {
        let entry = LogEntry {
            time_millis: std::time::SystemTime::now()
                .duration_since(std::time::SystemTime::UNIX_EPOCH)
                .unwrap()
                .as_millis(),
            level: match record.level() {
                Level::Trace => LogLevel::Trace,
                Level::Debug => LogLevel::Debug,
                Level::Info => LogLevel::Info,
                Level::Warn => LogLevel::Warn,
                Level::Error => LogLevel::Error,
            },
            tag: record.target().to_string(),
            msg: record.args().to_string(),
        };
        self.0.clone().on_next(entry);
    }

    fn flush(&self) {}
}

pub fn get_logger_observable() -> impl Observable<'static, 'static, LogEntry, Infallible> {
    if log::set_logger(APP_LOGGER.deref()).is_ok() {
        log::set_max_level(LevelFilter::Debug);
    }
    APP_LOGGER.0.clone()
}
