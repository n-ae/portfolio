use thirtyfour::prelude::*;
#[macro_use]
extern crate dotenv_codegen;

mod linkedin;
use linkedin::login::login;

#[tokio::main]
pub async fn main() -> WebDriverResult<()> {
    let caps = DesiredCapabilities::chrome();
    let driver = WebDriver::new("http://localhost:9515", caps).await?;
    login(&driver).await?;
    driver.quit().await?;

    Ok(())
}
