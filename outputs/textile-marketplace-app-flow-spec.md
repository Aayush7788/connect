# Textile Marketplace Android MVP App Flow Specification

Date: 2026-07-04
Status: Product-flow specification
Source: `outputs/textile-marketplace-app-flow-discovery.md`

## 1. Product Flow Decision

The MVP should be designed as a guided Android marketplace app, not as a generic listings app.

The user must first enter name and mobile number, verify mobile OTP, then choose a profile role. After the role is selected and saved to the account/profile, every user sees the same main home screen with three discovery paths:

- Find Manufacturer / Business
- Find Job Worker / Value Adder
- Find Skilled Worker / Karigar

The user's own role is stored for their profile and profile-completion flow, but it does not limit what they can search.

## 2. MVP Screen List

Required Android MVP screens:

1. Splash
2. Create Account
3. OTP Verification
4. Select Role
5. Home
6. Search
7. Result List
8. Profile Detail
9. My Profile
10. Edit Profile
11. Add Work Card
12. Add Work Needed Post
13. Saved
14. Notifications
15. Report
16. Settings

Admin dashboard is required later as a separate web/admin product surface, not part of the Android user app flow in this document.

## 3. Bottom Navigation

Bottom navigation tabs:

- Home
- Search
- Saved
- My Profile

Notifications are opened from a bell icon at the top-right.

Settings should be reachable from My Profile or a top-right menu inside My Profile.

## 4. First Open And Account Flow

### 4.1 Splash

Purpose:

- Show app logo briefly.
- Route user based on login state.

Behavior:

- If user is already logged in, go to Home.
- If user is not logged in, go to Create Account / OTP.

Logo and visual identity will be designed later.

### 4.2 Create Account / OTP / Select Role

New user fields:

- Mobile number
- Name

Role selection happens after OTP verification:

  - Manufacturer / Business
  - Job Worker / Value Adder
  - Skilled Worker / Karigar

Flow:

1. User enters mobile number and name.
2. User taps Continue / Get OTP.
3. App sends OTP.
4. User enters OTP.
5. If OTP succeeds, app opens Select Role.
6. User selects Manufacturer / Business, Job Worker / Value Adder, or Skilled Worker / Karigar.
7. App saves the selected role to the user's account/profile.
8. App opens Home.
9. If OTP fails, user can resend OTP or use contact support later.

Rules:

- No search before account creation.
- Mobile OTP is required even for private demo.
- User cannot skip role selection after OTP verification.
- One mobile number maps to one account.
- Once profile is completed, role cannot be changed.
- If user wants a different role later, they must terminate the account and create a new account/profile with the desired role.

## 5. Home Screen

Home is the guided discovery screen.

Top area:

- App header
- Notification bell
- Optional settings/profile menu access

Main content:

- Prompt: "What do you want to find?"
- Three large buttons/cards:
  - Find Manufacturer / Business
  - Find Job Worker / Value Adder
  - Find Skilled Worker / Karigar

Below main buttons:

- Complete Profile banner if profile is incomplete.
- Profile improvement reminders, such as "Add 3 work photos to improve ranking."

Empty/incomplete state:

- Always show three find buttons.
- If profile is incomplete, show Complete Profile banner.

Home is the same for all roles.

## 6. Search Screen

Search is global, but results are viewed one persona type at a time.

Search screen structure:

- Search bar
- Filter button
- Persona result tabs:
  - Businesses
  - Job Workers
  - Karigars
- Result list for the active tab

Search behavior:

- User can type first, then filter.
- User can filter first, then type.
- App handles both.
- If user searches "flat hemming", results are separated by tabs:
  - Job Worker matches
  - Manufacturer matches
  - Karigar matches
- User selects a tab to see that result list.

MVP filters:

- Category / work type
- Product type
- Verified

Filters are hidden behind a filter button. When tapped, filter selection options appear.

Default list before search:

- Show verified profiles first.
- Then nearby/local profiles.
- Then most complete profiles.
- Display as cards.

Sorting:

- Sorting should exist.
- Candidate sort options:
  - Verified first
  - Nearby/locality
  - Most complete
  - Newest
  - Most work photos

No result state:

- Show request-this-work option.
- Ask user to invite someone onto the app.

## 7. Result List Cards

### 7.1 Manufacturer / Business Cards

Card should show:

- Photos of what the manufacturer makes
- Business name
- Type of business/work they do
- Categories the manufacturer belongs to
- Verified blue tick if fully verified

Card should not show direct contact/address. Contact/address appears after opening the profile.

Click behavior:

- Opens manufacturer detail with Work Needed Posts selected by default.

### 7.2 Job Worker / Value Adder Cards

Job-worker search should show the work entry first, not only the person/profile.

Card should show:

- Work entry photos
- Work name
- Job worker/workshop name below
- Verified blue tick if fully verified

Click behavior:

- Opens all work entries by that job worker by default.
- User can switch to View Profile from the header.

### 7.3 Skilled Worker / Karigar Cards

Card should show:

- Worker photo
- Work/skill they do
- Experience
- Name
- Verified blue tick if fully verified

Phone/address should not be shown on result cards. They appear after opening the profile.

## 8. Profile Detail Screens

All profile detail screens can show action buttons:

- Call
- WhatsApp
- Save as favourite
- Share
- Report

MVP contact rule:

- Contact number and address are directly visible on the profile in MVP.
- Later this changes to a Show Contact button for contact reveal tracking.
- Even in MVP, Call and WhatsApp taps should be tracked silently for analytics.

Image behavior:

- Work/profile photos open in a full-screen gallery.

Verification display:

- Public users only see a blue tick if the profile is fully verified.
- Do not show detailed verification statuses publicly.
- If not fully verified, show no blue tick.

Similar profiles:

- Show similar profiles below the profile if feasible.
- This can be reduced if MVP timeline becomes tight.

### 8.1 Manufacturer / Business Detail

Header options:

- Work Needed Posts
- View Profile

Default tab:

- Work Needed Posts

Work Needed Posts shows:

- Active work-needed post cards
- Photos for what the manufacturer is looking for
- Work type
- Category
- Product type
- Description
- Status if relevant

View Profile shows:

- Business name
- Blue tick if verified
- Workplace photos
- Owner name
- What they manufacture
- Contact
- Address

### 8.2 Job Worker / Value Adder Detail

Header options:

- Work List
- View Profile

Default tab:

- Work List

Work List shows cards:

- Work photos
- Type of work
- Work name

View Profile shows:

- Job-worker business/workshop name
- Blue tick if verified
- Workplace/shop photos
- Job worker name
- Type of work they do
- Contact
- Address

### 8.3 Skilled Worker / Karigar Detail

Show:

- Karigar name
- Karigar photo
- Type of work they do
- Mastery/expertise
- Experience
- Address
- Contact number
- Actions: Call, WhatsApp, Save, Share, Report

No separate Work List is required for skilled workers in MVP.

## 9. My Profile

My Profile is the owner's control center.

Top section:

- Name
- Role
- Completion percentage
- Edit button
- Verification status for owner

My Profile should show the same public preview others see, plus owner-only controls.

Profile completeness is visible only to the owner, not public visitors.

### 9.1 Manufacturer / Business My Profile Actions

Actions:

- Edit profile
- Add work-needed post
- View my posts
- Add photos in selected work-needed card
- Submit verification
- Hide profile from search

For MVP, My Posts lives inside My Profile. A separate My Posts screen may come later.

### 9.2 Job Worker / Value Adder My Profile Actions

Actions:

- Edit profile
- View and Add Work
- Add work card
- Edit work card
- Add photos in work card
- Delete work card
- Submit verification
- Hide profile from search

For MVP, My Work lives inside My Profile. A separate My Work screen may come later.

### 9.3 Skilled Worker / Karigar My Profile Actions

Actions:

- Edit profile
- Submit verification when eligible
- Hide profile from search

No separate My Skills screen in MVP.

## 10. Profile Creation Flow

After OTP, user selects a role, then goes to Home. The app shows Complete Profile prompt.

Profile creation uses step-by-step screens, not one long form.

User can save incomplete profile and complete later.

Profile appears in search only after role-specific minimum fields are complete.

After profile completion:

1. Show profile preview.
2. Let user return to Home.
3. If eligible, allow verification submission.

### 10.1 Manufacturer / Business Profile Creation

Fields:

- Business name
- Owner name
- What they manufacture
- Category
- Address
- Photos

GST comes later.

### 10.2 Job Worker / Value Adder Profile Creation

Fields:

- Business/workshop name
- Owner name
- What work they do
- Work category

Work cards are added separately.

### 10.3 Skilled Worker / Karigar Profile Creation

Fields:

- Name
- Mastery/skill
- Experience
- Address
- Contact

### 10.4 Photo Rules

Profile flow:

- Target minimum: 3 photos.

Work card flow:

- Minimum: 1 photo.
- Cannot save a work card with 0 photos.

## 11. Edit Profile Flow

Entry:

- My Profile -> Edit

Behavior:

- Edit opens a long editable form with current data filled.
- It does not reopen the step-by-step onboarding flow.
- User directly changes the fields they need to change.

Locked fields:

- Mobile number cannot be changed.
- Owner name cannot be changed.
- Role cannot be changed once profile is completed.

Reverification:

- If verified-profile fields change, blue tick is removed immediately.
- Profile must be verified again.

Profile hiding:

- User can temporarily hide profile from search.

## 12. Add Work Card Flow

For job workers/value adders.

Entry:

- My Profile -> View and Add Work -> Add Work

Work-list screen:

- Shows previous work cards.
- Shows Add Work button.

Add Work flow:

1. Select work category.
2. If category is missing, user can type category.
3. Select work name.
4. If work name is missing, user can type work name.
5. Select product type.
6. Add at least 1 photo.
7. Add description.
8. Save/publish.

Fields:

- Category
- Work name
- Product type
- Photos
- Description

Rules:

- One work card has one category.
- Product type is mandatory.
- Can publish immediately.
- No admin approval required in MVP.
- Job worker can add multiple work cards.
- User can edit/delete work cards from My Profile.

## 13. Add Work Needed Post Flow

For manufacturers/businesses.

Entry:

- My Profile -> Work Needed -> Add Work Needed

Work Needed area:

- Shows two options:
  - Add Work Needed
  - View Profile

Fields:

- Work type
- Category
- Product type
- Photos
- Description

Photo purpose:

- Photos should show what the manufacturer wants or what kind of work they are looking for.

Rules:

- Posts publish immediately.
- No admin approval required in MVP.
- Manufacturer can edit, delete, pause, or close a post.

Statuses:

- Active
- Paused
- Closed

Job-worker interaction:

- When job worker clicks a work-needed post, they land on that manufacturer's Work Needed area.
- They can see all work-needed posts from that manufacturer.
- They can switch to View Profile and contact the manufacturer.

## 14. Verification Flow

Entry:

- My Profile

Eligibility:

- Verification becomes available only after required/full profile fields and photos are complete.

Button:

- Use a button such as "Verify and Save My Profile" or "Submit for Verification".

No separate long verification intro screen in MVP.

### 14.1 Uploads By Role

Manufacturer/business:

- Shop photos
- Identity proof optional
- GST proof optional

Job worker/value adder:

- Workplace/shop photos
- Work proof/photos
- Identity proof optional
- GST proof optional if available/applicable

Skilled worker/karigar:

- Profile/basic identity details
- Skill/work details
- Identity proof optional
- Address/contact details

### 14.2 Verification Status

User sees:

- Pending review
- Approved
- Rejected
- Changes requested

If approved:

- Blue tick becomes visible.

If rejected/changes requested:

- Owner sees message explaining what to change or add.
- Message appears in My Profile and Notifications.

Rules:

- User cannot edit profile while verification is pending.
- If important fields change after verification, blue tick is removed and reverification is needed.
- Verification is not required for search visibility.
- Unverified profiles appear lower than complete/verified profiles.
- Verification is free in MVP and should remain free later.

## 15. Saved

Saved is a bottom-nav tab.

User can save:

- Profiles
- Work cards
- Work-needed posts

Saved items should be grouped.

Suggested groups:

- Manufacturers / Businesses
- Job Workers / Work Cards
- Karigars
- Work Needed Posts

Empty state:

- "No saved items yet."

Internet:

- Saved items are not fully available offline in MVP.
- Internet is required.

## 16. Share

Share can be used for:

- Profile link
- Work card
- Work-needed post
- App install invite

Share targets:

- WhatsApp
- X
- LinkedIn
- Email
- Other system share options

Shared link behavior:

- If app is installed, open directly in the app.
- If app is not installed, send user to Play Store to download, then view the shared item.

Deep-link technical implementation will be decided later.

## 17. Report

Report entry:

- Profile action button
- Work card action if needed
- Work-needed post action if needed

Report reasons:

- Fake profile
- Wrong contact
- Wrong category
- Inappropriate photo
- Spam

Report form:

- User selects reason.
- User can optionally type details.

After submission:

- Show confirmation.
- User can see report status.

Admin analytics:

- Reported actions should be visible to admin.

## 18. Notifications

Entry:

- Bell icon top-right.

MVP notification types:

- Verification submitted
- Verification approved
- Verification rejected
- Changes requested
- Profile completion reminders

Delivery:

- Push notification.
- In-app notification list.

Settings:

- User can turn notifications off inside Settings.
- Verification/status notifications may need to remain mandatory or treated carefully during implementation.

## 19. Settings

MVP Settings should include:

- Notification settings
- Logout
- Contact support later

Future settings can include:

- Terms and privacy
- Account termination
- Language
- Help
- App version

## 20. Empty, Loading, And Error States

Loading:

- Show skeleton/cards while results are loading.

Slow/no internet:

- Show retry.
- Continue trying to load new data.
- After some time, show connection issue.

Image upload failure:

- Allow retry.
- Save draft.

OTP failure:

- Resend OTP.
- Contact support later.

Empty states:

- Home: three find buttons plus complete profile banner.
- Saved: "No saved items yet."
- My Profile incomplete: "Complete your profile."
- Job-worker Work List empty: "Add the work."
- Manufacturer Work Needed empty: "Find work by posting."
- No photos: show placeholder saying no photos and prompt owner to add photos.

## 21. Critical MVP User Journeys

### Journey 1: Manufacturer Finds Flat Hemming Job Worker

1. Manufacturer opens app.
2. App opens Home.
3. User taps Find Job Worker / Value Adder.
4. Job-worker browse screen opens with verified/complete profiles first.
5. User searches "flat hemming".
6. App shows matching work-entry cards.
7. User opens a work card.
8. App shows all work entries by that job worker.
9. User taps View Profile.
10. User sees shop photos, work details, address, and contact.
11. User taps Call or WhatsApp.

### Journey 2: Job Worker Adds Work Card

1. Job worker opens app.
2. User taps My Profile.
3. User taps View and Add Work.
4. User sees existing work cards or empty state.
5. User taps Add Work.
6. User selects category.
7. User selects or types work name.
8. User selects product type.
9. User uploads at least one work photo.
10. User writes description.
11. User saves.
12. Work card publishes immediately.
13. Work card appears in profile and search.

### Journey 3: Manufacturer Posts Work Needed

1. Manufacturer opens app.
2. User taps My Profile.
3. User taps Work Needed.
4. User taps Add Work Needed.
5. User enters work type.
6. User selects category.
7. User selects product type.
8. User uploads photos showing what work is needed.
9. User writes description.
10. User publishes.
11. Post becomes active immediately.
12. Job workers can discover the post and contact the manufacturer through the profile.

## 22. Deliberately Postponed

Not in MVP:

- Voice search
- Map
- iOS
- Payments
- Ratings
- Full support chat/call
- Provider KYC
- Contact reveal locking
- Advanced multilingual search
- Public admin-created seed marker

## 23. Open Decisions For Wireframe

These do not block app-flow spec, but should be resolved while creating the wireframe:

- Exact wording for the three home buttons.
- Exact tab labels: Work Needed Posts vs Needs, Work List vs Works, View Profile vs Profile.
- Exact Saved group labels and order.
- Exact empty-state text.
- Exact Settings contents.
- Whether similar profiles are included in MVP wireframe or left out if crowded.
- How strongly to display profile completion reminders without making the app annoying.
