import requests
from bs4 import BeautifulSoup

# 크롤링할 기본 URL
base_url = "https://www.crazy11.co.kr/shop/shopbrand.html"

# HTTP 요청 헤더
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

# 링크를 저장할 리스트
all_links = []

# 페이지 번호를 1부터 10까지 반복
for page in range(1, 11):
    # 페이지 URL 생성
    params = {
        "type": "Y",
        "xcode": "257",
        "sort": "",
        "page": str(page),
    }
    response = requests.get(base_url, headers=headers, params=params)
    response.raise_for_status()  # HTTP 에러 확인

    # HTML 파싱
    soup = BeautifulSoup(response.text, 'html.parser')

    # 현재 페이지에서 링크 추출
    for a_tag in soup.select('a.itemInfo'):
        href = a_tag.get('href')
        if href and href.startswith('/shop/shopdetail.html'):
            full_url = "https://www.crazy11.co.kr" + href
            all_links.append(full_url)

# 결과 출력
print("Extracted Links:")
for link in all_links:
    print(link)
