from django.urls import path, include
from . import views

urlpatterns = [
    path('users/', views.UserModelApi.as_view()),
    path('auth/login/', views.LoginView.as_view(), name='login'),
    path('auth/logout/', views.LogoutView.as_view(), name='logout'),
]