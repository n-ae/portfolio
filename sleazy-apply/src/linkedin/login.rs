use thirtyfour::prelude::*;

pub async fn login(driver: &WebDriver) -> WebDriverResult<()> {
    driver.goto("https://linkedin.com").await?;
    let username = driver.find(By::Name("session_key")).await?;
    username
        .send_keys(dotenv!("LINKEDIN_USERNAME").to_string())
        .await?;
    let password = driver.find(By::Name("session_password")).await?;
    password
        .send_keys(dotenv!("LINKEDIN_PASSWORD").to_string())
        .await?;

    driver
        .find(By::Css("button[class*='sign-in-form__submit-btn']"))
        .await?
        .click()
        .await?;
    Ok(())
}
