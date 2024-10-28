from rest_framework import serializers
from users.models import (
    User,
    Profile
    )
from classmate.models import (
    Departments,
    Sections,
    Intakes,
    Student,
)

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['role', 'email', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        user = User(
            email=validated_data['email'],
            role=validated_data['role']
        )
        user.set_password(validated_data['password'])  # Hash the password
        user.save()
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = '__all__'
