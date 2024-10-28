from rest_framework import generics, serializers
from users.models import User, Profile
from .serializers import UserSerializer, UserProfileSerializer
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework import status
from django.contrib.auth import authenticate
from rest_framework.permissions import AllowAny
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated

# 01 - For User list view and create API
# API for get and post==>>
class UserModelApi(generics.ListCreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    # # Add authentication classes to enforce JWT tokens
    # authentication_classes = [JWTAuthentication]  # Ensure JWT tokens are used
    # permission_classes = [IsAuthenticated]  # Restrict access to authenticated users only

# =============== 01 END ========================
'''
NOTE: we can add profile with the user api also MAYBE. Have to think
'''
# 02 - For User Login create API

class LoginView(APIView):
    permission_classes = [AllowAny]  # This ensures login is accessible without authentication

    def post(self, request):
        email = request.data.get("email")
        password = request.data.get("password")
        user = authenticate(username=email, password=password)
        
        if user is not None:
            token, _ = Token.objects.get_or_create(user=user)
            return Response({"token": token.key}, status=status.HTTP_200_OK)
        else:
            return Response({"error": "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)
# =============== 01 END ========================


# 03 - For Logout  API

class LogoutView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            request.user.auth_token.delete()
            return Response({"message": "Logged out successfully"}, status=status.HTTP_200_OK)
        except (AttributeError, Token.DoesNotExist):
            return Response({"error": "User is not logged in"}, status=status.HTTP_400_BAD_REQUEST)
# =============== 01 END ========================
