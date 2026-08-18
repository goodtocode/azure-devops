# Pull Request Checklist
## General Guidelines
1. At least two code reviewers per PR
1. Boyscout Rule: leave the campground cleaner than you found it
1. Write code without needing comments
1. Ensure the PR title and description are clear and concise
1. Link any related issues or tasks
1. Ensure the PR is focused on a single PBI or bug fix
1. Verify that the PR does not introduce breaking changes 
1. If PR is time sensitive and changes cannot be made immediately then changes needed to be added to a tech debt PBI 
1. Feature exists on a context diagram/blueprint 

## Modularity (Logical Grouping Related Code)
- [ ] I can see the Module on the Context Diagram 
- [ ] Confirm that any new changes are necessary and do not impact other isolated business modules
- [ ] Confirm feature folder and naming conventions and namespaces align with architectural blueprint

## Code Quality
- [ ] Confirm code is follow .NET coding conventions and naming guidelines using: Editor.config and https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions
- [ ] Ensure any commented-out code or unnecessary debug statements do not exist
- [ ] Confirm variables and method names have meaningful and easy-to-understand names based on UL
- [ ] Methods or variables with zero dependencies should be removed

## Testability (Core Features)
- [ ] Confirm each core feature has at least one passing unit test
- [ ] Confirm each core feature unit test scenarios are easy to read and match the UL
- [ ] Confirm each core feature unit test scenarios have a case of acceptance

## Security
- [ ] Input Validation: Verify all user inputs are validated
- [ ] Authentication and Authorization: Verify proper authentication and authorization mechanisms are in place
- [ ] Dependency Management: Confirm secure versions of dependencies
- [ ] CSRF Protection: Ensure Cross-Site Request Forgery protection is in place | All forms must have anti forgery tokens and backend validate anti forgery token
- [ ] XSS Protection: Validate and sanitize user inputs to prevent Cross-Site Scripting
- [ ] SQL Injection: Use parameterized queries to prevent SQL injection

## Final Check Pre PR (3'rd Party Vendors) :
- [ ] Run the application to ensure it works as expected.
- [ ] I have confirmed all unit tests are passing.
- [ ] I have double checked for any console errors or warnings.
- [ ] I confirm that all new features are functioning correctly.
- [ ] This branch is based on main, contains only this feature and has been rebased