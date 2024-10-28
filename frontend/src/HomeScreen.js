// Inside HomeScreen.js
import React, { useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import Icon from 'react-native-vector-icons/Ionicons';
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

export default function HomeScreen({ navigation }) {
  useEffect(() => {
    const checkAuth = async () => {
      const token = await AsyncStorage.getItem('token');
      if (!token) {
        navigation.replace('Login');
      }
    };
    checkAuth();
  }, []);

  const handleLogout = async () => {
    try {
      const token = await AsyncStorage.getItem('token');
      await axios.post(
        'http://192.168.0.193:8000/api/auth/logout/',
        {},
        { headers: { Authorization: `Token ${token}` } }
      );
      await AsyncStorage.removeItem('token'); // Remove token from storage
      Alert.alert('Logged out', 'You have been logged out.');
      navigation.replace('Login'); // Navigate back to Login screen
    } catch (error) {
      console.error('Logout error:', error);
      Alert.alert('Error', 'Logout failed. Please try again.');
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      {/* Header Section */}
      <View style={styles.header}>
        <Text style={styles.userName}>Md Emran Hossan Ashiq</Text>
        <Text style={styles.userId}>21224103147</Text>
      </View>

      {/* Upcoming Exams Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Upcoming Exams</Text>
        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
          <View style={styles.examCard}>
            <Text style={styles.examTitle}>Data Mining</Text>
            <Text style={styles.examDetails}>CSE 400</Text>
            <Text style={styles.examDate}>15 July, 2024</Text>
          </View>

          <View style={styles.examCard}>
            <Text style={styles.examTitle}>Data Mining</Text>
            <Text style={styles.examDetails}>CSE 400</Text>
            <Text style={styles.examDate}>10 July, 2024</Text>
          </View>
          <View style={styles.examCard}>
            <Text style={styles.examTitle}>Data Mining</Text>
            <Text style={styles.examDetails}>CSE 400</Text>
            <Text style={styles.examDate}>10 July, 2024</Text>
          </View>
        </ScrollView>
      </View>

      {/* Activities Section */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Activities</Text>
        <View style={styles.activities}>
          <View style={styles.activityBox}>
            <Text style={styles.activityNumber}>2</Text>
            <Text style={styles.activityLabel}>Pending Assignments</Text>
          </View>
          <View style={styles.activityBox}>
            <Text style={styles.activityNumber}>3</Text>
            <Text style={styles.activityLabel}>Pending Exams</Text>
          </View>
        </View>
        <View style={styles.activities}>
          <View style={styles.activityBox}>
            <Text style={styles.activityCountdown}>21</Text>
            <Text style={styles.activityLabel}>Mid Term in Days</Text>
          </View>
          <View style={styles.activityBox}>
            <Text style={styles.activityCountdown}>61</Text>
            <Text style={styles.activityLabel}>Final in Days</Text>
          </View>
        </View>
      </View>

      {/* Bottom Action Buttons */}
      <View style={styles.actionButtons}>
        <TouchableOpacity style={styles.actionButton}>
          <Icon name="home-outline" size={30} color="#fff" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.actionButton}>
          <Icon name="calendar-outline" size={30} color="#fff" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.actionButton}>
          <Icon name="book-outline" size={30} color="#fff" />
        </TouchableOpacity>
        <TouchableOpacity style={styles.actionButton}>
          <Icon name="settings-outline" size={30} color="#fff" />
        </TouchableOpacity>
      </View>

      {/* Logout Button */}
      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Text style={styles.logoutButtonText}>Logout</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: '#f3f4f6',
    padding: 16,
  },
  header: {
    backgroundColor: '#1f2937',
    padding: 20,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 16,
  },
  userName: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  userId: {
    color: '#9ca3af',
    marginTop: 4,
  },
  section: {
    marginBottom: 24,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
    color: '#374151',
  },
  examCard: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 8,
    marginRight: 12,
    width: 150,
    alignItems: 'center',
  },
  examTitle: {
    fontSize: 16,
    fontWeight: 'bold',
  },
  examDetails: {
    color: '#6b7280',
    marginBottom: 4,
  },
  examDate: {
    color: '#10b981',
  },
  activities: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  activityBox: {
    backgroundColor: '#fff',
    flex: 1,
    padding: 16,
    marginHorizontal: 8,
    borderRadius: 8,
    alignItems: 'center',
  },
  activityNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#ef4444',
  },
  activityCountdown: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#3b82f6',
  },
  activityLabel: {
    marginTop: 8,
    color: '#6b7280',
    textAlign: 'center',
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 24,
  },
  actionButton: {
    backgroundColor: '#3b82f6',
    padding: 16,
    borderRadius: 50,
    alignItems: 'center',
  },
  logoutButton: {
    backgroundColor: '#ef4444',
    padding: 12,
    borderRadius: 4,
    alignItems: 'center',
    marginVertical: 20,
  },
  logoutButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});
