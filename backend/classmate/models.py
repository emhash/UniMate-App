from django.db import models
import uuid
from users.models import User

class CommonBaseModel(models.Model):
    uid = models.UUIDField(primary_key=True, default= uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class Departments(CommonBaseModel):
    name = models.CharField(max_length=150)
    short_name = models.CharField(max_length=50)
    department_chairman_name = models.CharField(max_length=350)
    chairman_room = models.CharField(max_length=150, null=True, blank=True)

    def __str__(self):
        return self.short_name
    

class Sections(CommonBaseModel):
    name = models.CharField(max_length=50)
    section = models.PositiveIntegerField()
    def __str__(self):
        return f"Sec: {self.section}"
    

class Intakes(CommonBaseModel):
    intake = models.PositiveIntegerField()

    def __str__(self):
        return f"Inake: {self.intake}"
    

GENDERS = [
    ('male',"Male"),
    ('female', "Female"),
]

class CommonProfileModel(models.Model):
    uid = models.UUIDField(primary_key=True, default= uuid.uuid4, editable=False)
    account = models.OneToOneField(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    personal_id = models.CharField(unique=True, max_length=150)
    gender = models.CharField( max_length=50, choices=GENDERS, blank=True,null=True)
    image = models.FileField(upload_to="Profile_Pictures", null=True, blank=True)
        
    class Meta:
        abstract = True
        
    def save(self, *args, **kwargs):
        if not self.image:
            if self.gender == "male":
                self.image.name = "avatar-male.svg"
            elif self.gender == "female":
                self.image.name = "avatar-female.svg"
        super().save(*args, **kwargs)

class Student(CommonProfileModel):
    name = models.CharField(max_length=350)
    intake = models.ForeignKey(Intakes, on_delete=models.CASCADE)
    section = models.ForeignKey(Sections, on_delete=models.CASCADE)
    department = models.ForeignKey(Departments, on_delete=models.CASCADE)
    shift = models.CharField(max_length=50, choices= [("Day","day"), ("Evening", "evening")])
    is_class_cr = models.BooleanField(default=False)
    contact_number = models.PositiveIntegerField(null=True, blank=True)
    facebook_profile = models.CharField( max_length=500, null=True, blank=True)
    
    def __str__(self):
        return self.name
    

class Teacher(CommonProfileModel):
    name = models.CharField(max_length=350)
    department = models.ForeignKey(Departments, on_delete=models.CASCADE)
    is_intake_incharge = models.BooleanField(default=False)

    def __str__(self):
        return self.name

