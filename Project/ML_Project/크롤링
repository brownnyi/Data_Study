import requests
from bs4 import BeautifulSoup
import time

def get_soup(url: str) -> BeautifulSoup:
    """URL로부터 BeautifulSoup 객체를 생성하는 함수"""
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    response = requests.get(url, headers=headers)
    return BeautifulSoup(response.text, 'html.parser')

def visit_product_pages(base_url: str):
    """각 상품 페이지를 방문하고 다음 페이지로 이동하는 함수"""
    current_url = base_url
    page_num = 1
    
    while True:
        try:
            print(f"\n현재 페이지 {page_num} 처리 중...")
            
            # 현재 페이지의 HTML 가져오기
            soup = get_soup(current_url)
            
            # 상품 링크들 찾기
            product_elements = soup.find_all('a', class_='itemInfo')
            
            # 각 상품 페이지 방문
            for i, element in enumerate(product_elements, 1):
                product_url = f"https://www.crazy11.co.kr{element['href']}"
                print(f"상품 방문: {i}/{len(product_elements)} - {product_url}")
                
                # 상품 페이지 방문
                product_soup = get_soup(product_url)
                time.sleep(1)  # 서버 부하 방지
            
            # 다음 페이지 URL 찾기
            next_url = None
            paging = soup.find('ol', class_='paging')
            if paging:
                current_li = paging.find('li', class_='now')
                if current_li:
                    next_li = current_li.find_next_sibling('li')
                    if next_li and next_li.find('a'):
                        next_url = f"https://www.crazy11.co.kr{next_li.find('a')['href']}"
            
            if not next_url:
                print("\n마지막 페이지에 도달했습니다.")
                break
                
            current_url = next_url
            page_num += 1
            time.sleep(1)  # 서버 부하 방지
            
        except KeyboardInterrupt:
            print("\n프로그램 중단됨...")
            break
        except Exception as e:
            print(f"\n에러 발생: {e}")
            break

def main():
    base_url = "https://www.crazy11.co.kr/shop/shopbrand.html?xcode=257&type=Y&gf_ref=Yz1iWFpVV2M="
    try:
        visit_product_pages(base_url)
    except KeyboardInterrupt:
        print("\n프로그램이 사용자에 의해 중단되었습니다.")

if __name__ == "__main__":
    main()
