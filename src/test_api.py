"""
File: test_api.py

Purpose:
Tests the  Alpha Vantage API connection by requesting daily
stock-market data for AAPL and displaying the response status
and returned data structure.
"""


import os
import requests
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("ALPHA_VANTAGE_API_KEY")

url = "https://www.alphavantage.co/query"

params = {
    "function": "TIME_SERIES_DAILY",
    "symbol": "AAPL",
    "outputsize": "compact",
    "apikey": API_KEY
}

response = requests.get(url, params=params, timeout=30)

print("HTTP Status:", response.status_code)

data = response.json()

print(data.keys())
print(data)