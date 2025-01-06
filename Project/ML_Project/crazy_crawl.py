import requests
from bs4 import BeautifulSoup

def extract_section_value(items, section_name):
    for item in items:
        if item.find('div', class_='mTC leftT') and item.find('div', class_='mTC leftT').text.strip() == section_name:
            value = item.find('div', class_='mcie on')
            return value.text.strip() if value else None
    return None

def extract_score(sections, score_name):
    for section in sections:
        if section.find('div', class_='bTC leftT') and section.find('div', class_='bTC leftT').text.strip() == score_name:
            inTB_elements = section.find_all('div', class_='inTB')
            for index, element in enumerate(inTB_elements, start=1):
                if 'on' in element.get('class', []):
                    return index
    return None

def crazy(url):
    response = requests.get(url)
    response.encoding = 'cp949'
    soup = BeautifulSoup(response.text, "html.parser")

    title_div = soup.find("div", class_="itemDetailPage-main-tit txts-22 txts-fontB txtc-46")
    title = title_div.text.strip() if title_div else "Unknown Title"

    items = soup.find_all('div', class_='mTR')
    upper = extract_section_value(items, '갑피')
    ground = extract_section_value(items, '구장')

    sections = soup.find_all('div', class_='bTR')
    len_score = extract_score(sections, '길이')
    foot_score = extract_score(sections, '발볼')

    result = {
        'title': title,
        'upper': upper,
        'ground': ground,
        'len_score': len_score,
        'foot_score': foot_score
    }

    return result


#예시
import pandas as pd

urls = ['https://www.crazy11.co.kr/shop/shopdetail.html?branduid=809113&xcode=257&mcode=003&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bm9%2BW1w%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=809112&xcode=257&mcode=003&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=bmd3UA%3D%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=809111&xcode=257&mcode=003&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=bm55W14%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=809110&xcode=257&mcode=003&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=bm59W18%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=809109&xcode=257&mcode=003&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=Zmd3VQ%3D%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=809006&xcode=257&mcode=005&scode=007&type=Y&sort=order&cur_code=257&search=&GfDT=bmt%2BW1k%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808976&xcode=257&mcode=004&scode=005&type=Y&sort=order&cur_code=257&search=&GfDT=bmp8W1o%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808974&xcode=257&mcode=004&scode=005&type=Y&sort=order&cur_code=257&search=&GfDT=Zmt3Vg%3D%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808868&xcode=257&mcode=002&scode=007&type=Y&sort=order&cur_code=257&search=&GfDT=bGV8VA%3D%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808866&xcode=257&mcode=002&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=aGp3UFo%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808865&xcode=257&mcode=002&scode=007&type=Y&sort=order&cur_code=257&search=&GfDT=bG53UFs%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808782&xcode=257&mcode=002&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bWZ3UFQ%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808761&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=Zm13UFU%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808726&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bm1%2BW15E',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808725&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bG93U10%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808669&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=Zmx3U14%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808665&xcode=257&mcode=003&scode=002&type=Y&sort=order&cur_code=257&search=&GfDT=bm10W15H',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808664&xcode=257&mcode=003&scode=002&type=Y&sort=order&cur_code=257&search=&GfDT=bm5%2FW15A',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808663&xcode=257&mcode=003&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=bml4W15B',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808662&xcode=257&mcode=003&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=bG53U1o%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808668&xcode=257&mcode=001&scode=002&type=Y&sort=order&cur_code=257&search=&GfDT=bm55W15D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808605&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bmZ3U1Q%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808604&xcode=257&mcode=001&scode=002&type=Y&sort=order&cur_code=257&search=&GfDT=aW93U1U%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808600&xcode=257&mcode=001&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=bm91W19E',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808599&xcode=257&mcode=001&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=aGt3Ul0%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808595&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bG93Ul4%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808594&xcode=257&mcode=001&scode=002&type=Y&sort=order&cur_code=257&search=&GfDT=a2Z3Ul8%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808572&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bm53Ulg%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808608&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bm11W19B',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808607&xcode=257&mcode=001&scode=001&type=Y&sort=order&cur_code=257&search=&GfDT=bmt5W19C',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808603&xcode=257&mcode=001&scode=002&type=Y&sort=order&cur_code=257&search=&GfDT=bm55W19D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808596&xcode=257&mcode=001&scode=003&type=Y&sort=order&cur_code=257&search=&GfDT=bmV%2BWQ%3D%3D',
        'https://www.crazy11.co.kr/shop/shopdetail.html?branduid=808654&xcode=257&mcode=004&scode=007&type=Y&sort=order&cur_code=257&search=&GfDT=bm19W19N']

data_list = []

for url in urls:
    try:
        result = crazy(url)
        data_list.append(result)
    except Exception as e:
        print(f"Error: {url}: {e}")

df = pd.DataFrame(data_list)

df
