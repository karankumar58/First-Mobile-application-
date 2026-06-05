# Flutter CRUD API Integration Assignment

This Flutter project extends the previous multi-screen authentication app with REST API integration and full CRUD operations for course data.

## Branch Name

`feature/course-api-integration`

## API Used

- API: JSONPlaceholder
- Base URL: `https://jsonplaceholder.typicode.com`
- Course data endpoint used: `/posts`
- Official documentation followed: https://jsonplaceholder.typicode.com/guide

JSONPlaceholder uses `posts` resources with `id`, `userId`, `title`, and `body`. In this app, each post is treated as a course:

- `id` -> Course ID
- `title` -> Course title
- `body` -> Course description

## CRUD Features

| Operation | HTTP Method | Endpoint | App Feature |
|---|---|---|---|
| Read | GET | `/posts` | Fetch and display courses |
| Create | POST | `/posts` | Add a new course |
| Update | PUT | `/posts/{id}` | Edit an existing course |
| Delete | DELETE | `/posts/{id}` | Delete a course after confirmation |

## Assignment Requirements Covered

- Fetch courses from JSONPlaceholder API
- Display course title, ID, and description
- Show loading indicators during API calls
- Handle API error states
- Add a course using POST
- Edit a course with a pre-filled form using PUT
- Delete a course using DELETE with confirmation dialog
- Keep API logic in a separate service layer: `services/course_api_service.dart`
- Use reusable model class: `models/course_model.dart`
- Preserve existing authentication, validation, navigation, and theme structure

## Screenshots

Add screenshots of the following screens before final submission:

| Login | Courses List | Add Course | Edit Course | Course Detail |
|:---:|:---:|:---:|:---:|:---:|
| Add image | Add image | Add image | Add image | Add image |

## Project Structure

```text
lib/
├── main.dart
├── controllers/
│   └── auth_controller.dart
├── models/
│   ├── user_model.dart
│   └── course_model.dart
├── screens/
│   ├── login_screen.dart
│   ├── registration_screen.dart
│   ├── dashboard_screen.dart
│   ├── course_form_screen.dart
│   └── detail_screen.dart
├── services/
│   └── course_api_service.dart
├── utils/
│   └── app_theme.dart
└── validators/
    └── app_validator.dart
```

## How to Run

```bash
flutter pub get
flutter run
```

## Notes

JSONPlaceholder is a fake API for development. POST, PUT, and DELETE requests return successful responses, but changes are not permanently saved on the remote server. The app updates the local UI after successful responses so CRUD behavior is visible to the user.
