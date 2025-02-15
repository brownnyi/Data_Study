import re
import requests
from bs4 import BeautifulSoup

def extract_main_image(soup):
    img_tag = soup.select_one('.itemDetailPage-main-img img')
    if img_tag:
        img_url = img_tag.get('src')
        return f"https://www.crazy11.co.kr{img_url}" if img_url.startswith('/') else img_url
    return None

def extract_section_value(items, section_name):
    for item in items:
        if item.find('div', class_='mTC leftT') and item.find('div', class_='mTC leftT').text.strip() == section_name:
            values = item.find_all('div', class_='mcie on')
            return ", ".join([value.text.strip() for value in values]) if values else None
    return None

def extract_score(sections, score_name):
    for section in sections:
        if section.find('div', class_='bTC leftT') and section.find('div', class_='bTC leftT').text.strip() == score_name:
            inTB_elements = section.find_all('div', class_='inTB')
            for index, element in enumerate(inTB_elements, start=1):
                if 'on' in element.get('class', []):
                    return index
    return None

def extract_original_price(soup):
    price_span = soup.find("span", class_="itemDetailPage-price txtc-e4 txts-30")
    if price_span:
        original_price_span = price_span.find("span", class_="psale txts-18 txtc-a1")
        if original_price_span:
            return original_price_span.text.strip().replace(" 원", "").replace(",", "")
    return None

def extract_sale_price(soup):
    price_span = soup.find("span", class_="itemDetailPage-price txtc-e4 txts-30")
    if price_span:
        sale_price_text = price_span.contents[0].strip()
        return sale_price_text.replace(" 원", "").replace(",", "")
    return None

def extract_weight(soup):
    weight_sections = soup.find_all("span", class_="itembasic-bg")
    for section in weight_sections:
        title = section.find("span", class_="itembasic-tit")
        weight_text = section.find("span", class_="itembasic-txt")
        if title and weight_text and title.text.strip() == "무게":
            match = re.search(r'(\d+\.?\d*)g', weight_text.text.strip())
            if match:
                return match.group(1) + "g"
    return None

def crazy(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    response = requests.get(url, headers=headers)
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

    original_price = extract_original_price(soup)
    sale_price = extract_sale_price(soup)
    weight = extract_weight(soup)
    main_image = extract_main_image(soup)

    result = {
        'title': title,
        'original_price': original_price,
        'sale_price': sale_price,
        'upper': upper,
        'ground': ground,
        'len_score': len_score,
        'foot_score': foot_score,
        'weight': weight,
        'main_image': main_image
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
