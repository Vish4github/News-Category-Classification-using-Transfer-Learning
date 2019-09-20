from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
import datetime

driver = webdriver.Chrome(executable_path='C:\Users\Vishnu.Vijayakumar\Downloads\\chromedriver.exe')
driver.get("http://routementor.com")
login = driver.find_element_by_link_text("Employee Login")		#change to name / id
login.click()

username = driver.find_element_by_id("user_email")
password = driver.find_element_by_id("user_pwd")

username.send_keys("Vishnu.Vijayakumar@xe04.ey.com")
password.send_keys("Iamgoinghome@615")

driver.find_element_by_name("Login_submit").click()

driver.find_element_by_link_text('My Account').click()
driver.find_element_by_link_text('Add Schedule').click()


date = datetime.date.today()
driver.find_element_by_id(str(date)).click()

select = Select(driver.find_element_by_name('outtime'))
select.select_by_visible_text('18:00')

driver.find_element_by_id('btn_save').click()
#driver.find_element_by_link_text('Close').click()

#driver.close()