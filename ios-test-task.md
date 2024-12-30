# iOS Developer Test Task

## Technology Stack Requirements
- iOS 15+
- Navigation: UIKit
- UI Implementation: SwiftUI 
- Dependency Management: [Point-Free Dependencies](https://github.com/pointfreeco/swift-dependencies)
- Other technologies: at developer's discretion

## Task Description
Create an application implementing a user list with the following requirements:

### Architecture
- Implement unidirectional data flow architecture pattern
- Demonstrate clean separation of concerns and proper architectural layers

### Main Features

#### Timer Component
- Start countdown from 6:00:00
- Count down to zero
- Display "Submission closed!" message when timer reaches zero

#### User List
Each list item should display:
- avatar (mock image from assets);
- full name;
- username;
- market cap:
  - should be a cryptocurrency, but display as USD;
  - mocked data should be different for each user;
- graph visualization
  - mocked data should be different for each user;
  - display with 10 data points;
  - implement appropriate visualization.

! Market cap should be mocked for each user. It will have counted in units. This units converts somehow 

#### User Details Screen
- Screen contains all info about user.
- Navigation to this screen depends on position in the list:
  - first three items should have stack navigation;
  - other items should have modal navigation.
- Design on your choice.

### Data Requirements
- Fetch user data from: `https://jsonplaceholder.typicode.com/users`.
- You can fetch cryptocurrency exchange rates using `https://www.coinapi.io/` API.
- Exchange rates should be updated every 10 seconds.
- Handle the limited dataset (10 users) appropriately.
- Implement proper error handling and loading states.

### Optional Features
- Implement pull-to-refresh functionality for the user list

## Evaluation Criteria
- Architecture implementation and cleanliness
- Code style and documentation
- Error handling approach
- UI implementation quality
- Performance considerations
- Overall user experience

## Submission
Please provide:
- Source code with setup instructions
- Brief documentation explaining key decisions
