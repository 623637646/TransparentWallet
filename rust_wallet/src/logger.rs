use log::LevelFilter;
use log::{Level, Metadata, Record};
use rx_rust::disposable::subscription::Subscription;
use rx_rust::observable::Observable;
use rx_rust::observer::Observer;
use rx_rust::observer::boxed_observer::BoxedObserver;
use rx_rust::operators::creating::create::Create;
use std::convert::Infallible;
use std::sync::{Arc, Mutex, OnceLock};

pub fn init_logger_observable() -> impl Observable<'static, 'static, LogEntry, Infallible> {
    Create::new(|observer| {
        let logger = APP_LOGGER.get_or_init(|| {
            let logger = AppLogger(Arc::new(Mutex::new(None)));
            log::set_boxed_logger(Box::new(logger.clone())).expect("Failed to set logger");
            log::set_max_level(LevelFilter::Debug);
            logger
        });
        logger.0.lock().unwrap().replace(observer);
        Subscription::new_with_disposal_callback(|| {
            logger.0.lock().unwrap().take();
        })
    })
}

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

static APP_LOGGER: OnceLock<AppLogger> = OnceLock::new();

#[derive(Clone)]
struct AppLogger(Arc<Mutex<Option<BoxedObserver<'static, LogEntry, Infallible>>>>);

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
        self.0
            .lock()
            .unwrap()
            .as_mut()
            .expect("Logger not initialized")
            .on_next(entry);
    }

    fn flush(&self) {}
}
