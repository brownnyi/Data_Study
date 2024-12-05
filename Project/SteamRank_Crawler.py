from bs4 import BeautifulSoup
import requests

url = "https://profilerr.net/ko/services/steam-id/top-by-playtime/"
response = requests.get(url)

if response.status_code == 200:
    soup = BeautifulSoup(response.text, 'html.parser')
    
    links = soup.find_all('a', class_='_link_10zat_27')
    
    for link in links:
        user_name = link.find('span').text if link.find('span') else 'No Name'
        profile_link = link['href'] if 'href' in link.attrs else 'No Link'
        print(f"User Name: {user_name}, Profile Link: {profile_link}, SteamId: {profile_link.split('/')[5]}")
else:
    print(f"실패: {response.status_code}")
