@echo off
REM Change to project directory
cd /d "D:\DA Projects\FoodWasteManagement_Project_ShrutiGhosh\FoodWasteApp"

REM Activate virtual environment
call .venv\Scripts\activate.bat

REM Run Streamlit
python -m streamlit run app.py

pause
