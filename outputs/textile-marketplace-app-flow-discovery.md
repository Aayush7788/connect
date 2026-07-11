# Textile Marketplace App Flow Discovery

Date: 2026-07-03
Status: Converted into final app-flow spec at `outputs/textile-marketplace-app-flow-spec.md`

This file stores the product-flow decisions before Figma, database design, or coding. The goal is to decide how the app works screen by screen for the Android MVP.

## Locked Context From Previous Discovery

- MVP is Android first.
- MVP is for private demo/testing with selected Surat users.
- App supports three personas:
  - Persona A: textile businesses such as manufacturers, wholesalers, traders.
  - Persona B: value adders / job workers / workshops.
  - Persona C: skilled workers / karigars.
- Registration starts with mobile OTP, name, and role selection.
- One user account has exactly one profile.
- Onboarding should be short first; detailed profile completion happens later.
- Users can skip verification and complete it later.
- MVP contact/address visibility is free/open during private demo.
- MVP search should support category + keyword + aliases/local terms.
- MVP includes manufacturer work-needed posts.
- MVP does not include payments, ratings, support chat/call, voice search, offline drafts, iOS, or provider KYC.
- Push notifications in MVP are only for verification/status messages.
- Admin dashboard is basic first: profile approval, manual verification, categories, analytics, and user/profile management.

## Discovery Rounds

Answers will be appended here round by round.

## Round 1: App Opening, Login, Home Screen

### Confirmed Answers

1. **First app open**
   - New user sees account creation first.
   - User enters mobile number, name, and role selection.
   - User then receives OTP.
   - After OTP verification, user moves to the home screen.

2. **Search before login**
   - No search before account creation.
   - New users must create an account first.
   - After the user has an account, later app opens should go directly to home screen and allow search.

3. **Login requirement**
   - Login/account creation is only required for new users or logged-out users.
   - Returning logged-in users should open directly to home screen.

4. **Private demo OTP**
   - Mobile OTP and account creation should be required even in the private free demo.

5. **Role selection**
   - User must select role during account creation.
   - Roles:
     - manufacturer/business
     - job worker/value adder
     - skilled worker/karigar

6. **Skipping role selection**
   - User cannot skip role selection.
   - Role is saved to the profile/account.
   - User should be able to change role later.

7. **Home screen structure**
   - Home screen shows three main options asking what people/profile type the user wants to find.
   - Options:
     - manufacturer/business
     - job worker/value adder
     - skilled worker/karigar
   - When user selects one option, they enter that search/browse screen.
   - On that screen, user can search or browse profiles of the selected type.

8. **"What do you want to find" buttons**
   - Home screen should show all three options.
   - The purpose is to choose what profile type the user wants to find.

9. **Role-specific home screen**
   - Home screen should look the same for all roles.
   - A manufacturer, job worker, and skilled worker all see the same three discovery options.

10. **User's own role usage**
    - The selected role is stored as account/profile data.
    - This is useful for knowing which account is linked to which role.
    - The user's own role does not limit what they can search from the home screen.

11. **Incomplete profiles in search**
    - Incomplete profiles can appear in search.
    - Incomplete profiles should rank lower than complete profiles.
    - App should repeatedly encourage incomplete-profile users to complete their profile so they are more visible in search and get business.

12. **Unverified profiles in search**
    - Unverified profiles should appear in search during MVP.
    - Complete/verified profiles should rank higher.

13. **Profile completion prompt**
    - Home screen should show a "complete your profile" prompt if the user's profile is incomplete.
    - This should appear below the three main discovery buttons.
    - Settings option should also be available.

### Open Items From Round 1

- Decide exact wording for the three discovery buttons.
- Decide account creation order: mobile/name/role before OTP, or mobile first then OTP then name/role. Founder currently prefers mobile number, name, role, then OTP.
- Decide how role change works later and whether changing role resets profile fields.
- Decide whether the home screen should show categories or recent searches below the profile-completion prompt.
- Decide exact rules for incomplete-profile ranking.

## Round 2: Search/Browse Screen Flow

### Confirmed Answers

1. **Find Manufacturer/Business screen**
   - When user clicks "Find Manufacturer/Business", the next screen should show high-quality, verified manufacturer/business profiles first.
   - The screen should include a search bar.
   - When user searches for the business type they want, all related manufacturers/businesses should appear in a card list.
   - Manufacturer/business result cards should show:
     - photos of what the manufacturer makes
     - business name
     - type of work/business they do
     - categories the manufacturer belongs to
   - When user selects a manufacturer/business card, the user should first see work-needed posts from that manufacturing company if posts exist.
   - The selected manufacturer/business detail should also include a "View Profile" option.
   - View Profile shows:
     - work location
     - work location/shop photos
     - what exactly they manufacture
     - address
     - contact number
     - other profile details

2. **Find Job Worker/Value Adder screen**
   - When user clicks "Find Job Worker/Value Adder", the next screen should show verified and complete job-worker profiles first.
   - The screen should include a search bar where users can search any work.
   - Related job-worker results should appear as cards.
   - Job-worker result cards should focus on the job work/service they do.
   - A particular card should show:
     - the job work/service name
     - photos of that work
     - name of the job worker/workshop
   - When user selects a work card, all job works/services done by that job worker should be visible, including photos and work names.
   - The selected screen should also include a "View Profile" option.
   - View Profile shows:
     - name
     - address
     - contact number
     - shop/workplace photos
     - complete job-worker profile

3. **Find Skilled Worker/Karigar screen**
   - When user clicks "Find Skilled Worker/Karigar", the next screen should show highly complete profiles first.
   - The screen should include a search bar.
   - When user searches for what kind of karigar they want, related worker profiles should appear as cards.
   - Skilled worker/karigar cards should show:
     - worker photo
     - work/skill they do
     - experience
     - name
     - number
     - address

4. **Default list before search**
   - Yes, search/browse screens should show a list immediately before the user types anything.

5. **Default list ranking**
   - Default list should show:
     - verified profiles
     - nearby/local profiles
     - most complete profiles
   - Results should be shown as cards.

6. **MVP filters**
   - Filters visible from day one:
     - category/work type
     - product type
     - verified

7. **Filter UI**
   - Filters should be hidden behind a filter button.
   - When user clicks the filter button, selection options should appear.

8. **Search and filter order**
   - User can search first and then apply filters.
   - User can apply filters first and then search.
   - App should handle both flows.

9. **Job-worker result card model**
   - For job-worker search, result card should show the work entry first, not only the profile/person.
   - Card should show:
     - work entry photos uploaded for that work
     - work name
     - job-worker/workshop name below
   - When the card is clicked, user sees all works of that job worker with work photos and work names.
   - A separate option should allow user to view the full profile.

10. **Manufacturer/business result card model**
    - Manufacturer/business result card should show:
      - photos of what the manufacturer makes
      - business name
      - type of work/business they do
      - categories the manufacturer belongs to

11. **Skilled worker/karigar result card model**
    - Skilled worker/karigar card should show:
      - photo of the worker
      - work/skill they do
      - experience
      - name
      - number
      - address

12. **Phone/address visibility on cards**
    - Phone number and address should be shown only after opening the profile.
    - They should not be shown directly on result cards.

13. **Photos on result cards**
    - Yes, result cards should show work/photos directly.
    - Cards should also show the work name.

14. **Sorting**
    - User should be able to sort results.

15. **No search results**
    - If there are no results, app should:
      - allow/request "request this work"
      - ask user to invite someone onto the app

### Open Items From Round 2

- Decide exact selected-card intermediate screen name: "Work Details", "Business Needs", "All Work", or "Profile Preview".
- Clarify whether skilled worker/karigar cards should reveal phone/address on profile only, matching answer 12, even though answer 11 lists number/address as card data.
- Decide sort options: verified first, nearby/locality, most complete, newest, most work photos.
- Decide whether "request this work" is a simple no-result request to admin, a manufacturer work-needed post, or a future demand signal.
- Decide whether default "nearby" means same area, same city, or manually selected locality, since GPS is not locked for MVP.

## Round 3: Profile Detail Screens

### Confirmed Answers

1. **Manufacturer/business profile structure**
   - Top header has two options:
     - Work Needed Posts
     - View Profile
   - In View Profile, show:
     - business name
     - blue verified tick beside business name if fully verified
     - workplace photos
     - owner name
     - what they manufacture
     - contact
     - address

2. **Job worker/value adder profile structure**
   - Top header has two options:
     - Work List
     - View Profile
   - Work List shows cards.
   - Each work card shows:
     - photos of that work
     - type of work
     - work name
   - In View Profile, show:
     - job-worker business/workshop name
     - blue verified tick beside name if fully verified
     - workplace/shop photos
     - name of job worker
     - type of work they do
     - contact
     - address

3. **Skilled worker/karigar profile structure**
   - Show:
     - karigar name
     - karigar photo
     - type of work they do
     - mastery/expertise
     - experience
     - address
     - contact number

4. **Manufacturer card click behavior**
   - When user clicks a manufacturer card, Work Needed Posts should be shown first by default.
   - Header should include a View Profile button.
   - When user clicks View Profile, the full business profile opens.

5. **Job-worker work card click behavior**
   - When user clicks a job-worker work card, show all work entries by that job worker by default.
   - Header should include a View Profile option.

6. **Contact/address visibility in MVP**
   - For MVP, show contact number and address directly on the profile.
   - After everything works properly, implement a Show Contact button for tracking/contact reveal logic.

7. **Profile action buttons**
   - Profiles should include:
     - Call
     - WhatsApp
     - Save as favourite
     - Share
     - Report

8. **Image gallery**
   - Users should be able to open images in a full-screen gallery.

9. **Work photo grouping**
   - Work photos should be grouped by work type through work cards.
   - Job worker adds work through an Add Work button.
   - Add Work flow:
     - select work name from predefined options
     - if option is not present, choose Other and enter the work name
     - upload photos related to that work
     - add categories that the work belongs to
     - save as a work-type card on the job-worker profile

10. **Verification display**
    - Show only the blue tick if the profile is fully verified.
    - Do not show detailed verification statuses publicly.
    - If not fully verified, show no blue tick.

11. **Profile completeness visibility**
    - Profile completeness should be visible only to the profile owner.
    - It should not be shown publicly to visitors.

12. **Edit own profile**
    - Profile owner should see an edit option when viewing their own profile.
    - Edit profile should be accessible from settings.

13. **Similar profiles**
    - Show similar profiles below the profile.

14. **Request change / wrong information**
    - Do not add "request change / report wrong information" now.
    - This can be added later.
    - General Report button is still part of the profile actions from answer 7.

15. **No-photo state**
    - If the profile or work entry has no photos, show a placeholder saying no photos.
    - App should notify/prompt the profile owner to add photos.

### Open Items From Round 3

- Decide exact tab/header labels: "Work Needed Posts" vs "Needs", "Work List" vs "Works", "View Profile" vs "Profile".
- Decide whether Call/WhatsApp buttons should appear as separate buttons or one contact section.
- Decide whether Report exists in MVP if detailed wrong-information reporting is later.
- Decide exact placeholder text and whether no-photo profiles rank lower.
- Decide whether similar profiles are shown in MVP or can be delayed if timeline becomes tight.

## Round 4: Profile Creation and Completion Flow

### Confirmed Answers

1. **After OTP and role selection**
   - After account creation, take the user to the home screen.
   - Show a "Complete Profile" button/prompt on home.
   - Ask the user to complete their profile from there.

2. **Manufacturer/business profile creation fields**
   - First fields:
     - business name
     - owner name
     - what they manufacture
     - category
     - address
     - photos
   - GST comes later.

3. **Job worker/value adder profile creation fields**
   - First fields:
     - business/workshop name
     - owner name
     - what work they do
     - category of work they do

4. **Skilled worker/karigar profile creation fields**
   - First fields:
     - name
     - mastery/skill
     - experience
     - address
     - contact

5. **Profile creation format**
   - Use step-by-step screens.
   - Do not use one long form.

6. **Minimum photos**
   - User should upload minimum 3 photos.

7. **Incomplete profile saving**
   - User can save an incomplete profile and complete it later.

8. **Search visibility for incomplete profiles**
   - Profile should appear in search only after minimum fields are complete.

9. **Minimum fields for search**
   - Minimum fields depend on the user's role.
   - Exact role-wise minimum fields still need to be locked.

10. **Job worker Add Work fields**
    - Work name.
    - Category.
    - Product type.
    - Photos.
    - Description.

11. **Multiple work cards**
    - Job worker can add multiple work cards.
    - App should tell users to complete profile and add work cards for their own benefit.

12. **Manufacturer work-needed posts**
    - "Work needed" should not be part of initial profile creation.
    - It should be a separate "Add Work Needed Post" flow later.

13. **Profile completion percentage**
    - Show profile completion percentage after each step.

14. **After profile completion**
    - Show profile preview first.
    - Then user can go back to home screen.

15. **Profile editing**
    - Profile editing should happen from the My Profile screen.
    - It should not be mainly from Settings.

### Open Items From Round 4

- Define exact role-wise minimum fields required before search visibility.
- Decide whether minimum 3 photos means 3 profile/shop/workplace photos for all roles, or 3 photos only for business/job-worker profiles and 1 photo for skilled workers.
- Decide exact step order for each role's profile creation flow.
- Decide whether contact is prefilled from OTP mobile number or separately editable.
- Decide what profile preview screen should show and what actions appear there.

## Round 5: My Profile and Edit Flow

### Confirmed Answers

1. **My Profile access**
   - User should access My Profile from bottom navigation.

2. **Bottom navigation**
   - Bottom navigation should exist.
   - Tabs:
     - Home
     - Search
     - Saved
     - My Profile

3. **My Profile top section**
   - Profile owner should see:
     - name
     - role
     - completion percentage
     - edit button

4. **My Profile preview model**
   - My Profile should show the same public profile preview that other users see.
   - It should also show owner-only edit and completion controls.

5. **Manufacturer/business owner actions**
   - Edit profile.
   - Add work-needed posts.
   - View my posts.
   - Add photos in a selected work-needed card.
   - Submit verification.

6. **Job worker/value adder owner actions**
   - Edit profile.
   - Add work card.
   - Edit work card.
   - Add photos in a work card.
   - Submit verification.

7. **Skilled worker/karigar owner actions**
   - Edit profile.

8. **Edit profile behavior**
   - Edit profile should not reopen the original step-by-step onboarding flow.
   - It should open as a long/editable form where the user can directly change the needed fields.

9. **Sensitive fields and reverification**
   - User cannot change mobile number.
   - User cannot change owner name.
   - Other editable profile fields can be changed.
   - If verified-profile fields change, the profile has to be verified again.

10. **Delete photos/work cards**
    - Users can delete work cards.
    - Users should be able to manage work cards from My Profile.

11. **Temporarily hide profile**
    - User can temporarily hide their profile from search.
    - This supersedes the earlier MVP assumption that hide profile was not needed.

12. **Profile improvement tips**
    - User should see prompts such as "Add 3 work photos to improve ranking" if photos are pending.
    - These prompts should push profile completion and better search ranking.

13. **Search card preview**
    - My Profile should not show how the profile appears as a search-result card.

14. **Role change rule**
    - New rule: user cannot change role once selected and profile is completed.
    - If user wants another role, they must create a new account with another mobile number and complete a new profile.

15. **Changing role after completion**
    - No role change once selected and profile completed.
    - To change role, user must terminate the current account and then make a new full profile for the selected role.
    - Reason: every role has a different profile form and different profile data.

### Open Items From Round 5

- Define whether "terminate account" means delete, deactivate, or admin-assisted closure.
- Define whether profile hiding pauses search visibility only, or also hides direct profile links.
- Define exact fields that force reverification when edited.
- Decide whether deleting a work card is permanent or recoverable from admin.
- Decide whether skilled worker/karigar needs owner actions beyond edit profile, such as add skill photos or submit verification.

## Round 6: Add Work Card and Add Work-Needed Post Flow

### Confirmed Answers

1. **Job worker Add Work entry point**
   - Bottom navigation includes My Profile.
   - In My Profile, job worker should see two options:
     - View and Add Work
     - View Profile
   - When user selects View and Add Work, they move to a screen where previous work cards are listed.
   - Add Work button should be visible on that work-list screen.

2. **Add Work Card first step**
   - First select work category.
   - If category is not present, user can type the category name.
   - Then select work name.
   - If work name is not present, user can type the work name.

3. **Add Work Card fields**
   - Category.
   - Work name.
   - Photos.
   - Product type.
   - Description.
   - Keep the design flexible so future feedback can add/change fields.

4. **Categories per work card**
   - One work card has only one category.
   - Do not allow multiple categories on a single work card in MVP.

5. **Product type**
   - Product type is mandatory.

6. **Minimum photos per work card**
   - Work card can save with 1 photo.
   - Work card cannot save with 0 photos.

7. **Work card approval**
   - Job worker can publish a work card immediately.
   - Admin approval is not required before publishing work cards in MVP.

8. **Manufacturer Add Work Needed entry point**
   - In My Profile, manufacturer should see a Work Needed button.
   - When user clicks it, two buttons/options should appear:
     - Add Work Needed
     - View Profile

9. **Add Work Needed Post fields**
   - Work type.
   - Category.
   - Product type.
   - Photos.
   - Description.

10. **Work-needed post photos**
    - Manufacturer should upload photos.
    - Photos should show what they want / what kind of work they are looking for.

11. **Work-needed post approval**
    - Work-needed posts should appear immediately.
    - Admin approval is not required before publishing work-needed posts in MVP.

12. **Work-needed post status**
    - Manufacturer can change status.
    - Status values:
      - active
      - paused
      - closed

13. **Work-needed post controls**
    - Manufacturer can:
      - edit post
      - delete post
      - close post

14. **Job worker viewing work-needed post**
    - When job worker sees a work-needed post, clicking it takes them to that manufacturer's profile area.
    - All work-needed posts from that manufacturer should be visible.
    - A View Profile option should be available.
    - From View Profile, job worker can contact the manufacturer.

15. **No matching job workers**
    - If there are no matching job workers, show an invite job workers button.

### Open Items From Round 6

- Decide exact label for job-worker My Profile option: "View and Add Work", "My Work", or "Work List".
- Decide whether typed new category/work name goes live immediately or is flagged for admin taxonomy review.
- Decide whether delete means hard delete or hidden/archived for audit.
- Decide whether work-needed post photos require minimum 1 photo or minimum 3 photos.
- Decide whether a paused work-needed post is hidden from search/listing or visible with paused label.

## Round 7: Verification Flow

### Confirmed Answers

1. **Verification entry point**
   - User should start verification from My Profile.

2. **Verification eligibility**
   - Verification should be available only after minimum/full profile fields and photos are complete.

3. **Verification screen**
   - There should not be a separate long verification screen first.
   - Once user completes the full profile, they should get a button for "Verify and Save My Profile".

4. **Manufacturer/business verification uploads**
   - Shop photos.
   - Identity proof optional.
   - GST proof optional.

5. **Job worker/value adder verification uploads**
   - Use the already confirmed verification model from previous discovery:
     - workplace/shop photos
     - work proof/photos
     - identity proof optional
     - GST proof optional, if available/applicable
   - Admin manually reviews the uploaded evidence in MVP.

6. **Skilled worker/karigar verification uploads**
   - Use the already confirmed verification model from previous discovery:
     - profile/basic identity details
     - skill/work details
     - identity proof optional
     - address/contact details
   - Admin manually reviews the uploaded evidence in MVP.

7. **Submitting with missing fields**
   - User cannot submit verification if required fields are missing.
   - "Verify Profile" button should be active only after all required fields are complete.
   - Otherwise user can only save the profile.

8. **Verification status shown to user**
   - Pending review after submission.
   - If approved:
     - user sees approved status
     - blue tick becomes available
   - If rejected:
     - user sees rejected status
     - user sees message explaining what to change or add

9. **Admin-requested changes visibility**
   - Show change requests in My Profile.
   - Also show them in the notifications area/button.

10. **Editing during pending verification**
    - User cannot edit profile while verification is pending.

11. **Editing important fields after verification**
    - If user edits important fields after verification, blue tick should be removed immediately.
    - Verification status should become pending/reverification-needed again.

12. **Blue tick meaning in MVP**
    - In MVP, blue tick means admin manually checked profile, photos, and documents.
    - Later this can be automated with provider-based verification.

13. **Why profile is not verified**
    - Show reason only to the profile owner.
    - Do not show detailed unverified reasons publicly.

14. **Search visibility**
    - Verification is not required before profile appears in search.
    - Unverified profiles can appear in search, but with lower priority than complete/verified profiles.

15. **Verification pricing**
    - Verification is free in MVP.
    - Verification should remain free later also.

### Open Items From Round 7

- Define exact required fields per role before "Verify Profile" becomes active.
- Decide final button label: "Verify and Save My Profile", "Submit for Verification", or "Verify Profile".
- Decide whether optional identity/GST proof should become required later for blue tick.
- Decide exact important fields that trigger reverification when edited.
- Decide whether verification pending locks only profile edits or also work cards/work-needed posts.

## Round 8: Saved, Share, Report, Notifications

### Confirmed Answers

1. **Save/Favourite behavior**
   - When user taps Save/Favourite, that profile, work card, or work-needed post should directly come to the user's Saved section.
   - Saved is available from the footer/bottom navigation.

2. **Saved grouping**
   - Saved items should be grouped.

3. **What can be saved**
   - User can save anything useful:
     - profiles
     - individual work cards
     - work-needed posts

4. **Share behavior**
   - User should be able to share:
     - profile link
     - work card
     - work-needed post
     - app invite/install link
   - Share targets should include:
     - WhatsApp
     - X
     - LinkedIn
     - email
     - other available system share options

5. **Shared link behavior**
   - If app is installed, shared link should open directly in the app.
   - If app is not installed, link should take the user to Play Store to download the app, then view the shared item.

6. **Report reasons**
   - MVP report should allow:
     - fake profile
     - wrong contact
     - wrong category
     - inappropriate photo
     - spam

7. **Report input**
   - User should select a report reason.
   - User can also type additional details if they want.

8. **Report status**
   - After report submission, user should be able to see report status.

9. **Notifications location**
   - Notifications should live behind a bell icon at top-right.

10. **MVP notification types**
    - Verification submitted.
    - Verification approved.
    - Verification rejected.
    - Changes requested.

11. **Push and in-app notifications**
    - App should send push notifications.
    - App should also show an in-app notification list.

12. **Profile completion reminders**
    - Profile completion reminders should appear in both:
      - home banners
      - notifications

13. **Notification settings**
    - User should be able to turn notifications off inside app settings.

14. **Call/WhatsApp analytics**
    - Call and WhatsApp taps should be tracked silently for analytics in MVP.

15. **Admin analytics**
    - Saved, shared, reported, and contacted actions should be visible in admin analytics.

### Open Items From Round 8

- Define Saved grouping labels and order.
- Decide whether "save anything" includes manufacturer work-needed posts, job-worker work cards, and full profiles as separate saved item types.
- Decide deep-link implementation details later during technical design.
- Decide whether report status is only visible as submitted/reviewed/resolved, or includes admin message.
- Decide which notification categories can be turned off; verification/status notifications may need to stay mandatory.

## Round 9: Navigation, Search Tab, Empty States

### Confirmed Answers

1. **Home vs Search**
   - Home has the three main "find" buttons.
   - Search opens global search.

2. **Search tab behavior**
   - Bottom Search tab should show global search across all personas.

3. **Search tabs**
   - Search tab should have internal persona tabs:
     - Businesses
     - Job Workers
     - Karigars

4. **Search scope**
   - User should always search one persona type at a time.
   - The persona tabs control which result list is shown.

5. **Example search behavior**
   - If user searches "flat hemming", results should be separated by tabs:
     - Job Worker match
     - Manufacturer match
     - Karigar match
   - User selects a tab, then that list is shown.

6. **Slow/no internet**
   - Show retry.
   - Show cached saved items and continue trying to load new data.
   - If it still fails after some time, show connection issue.

7. **Saved offline**
   - Saved items should not be fully available without internet.
   - Internet should be required.

8. **Image upload failure**
   - Allow retry.
   - Save draft.

9. **OTP failure**
   - Allow resend OTP.
   - Provide contact support later.

10. **Empty/incomplete Home**
    - Show three find buttons.
    - Show complete profile banner.

11. **Empty Saved tab**
    - Show "No saved items yet".

12. **Empty My Profile before completion**
    - Show "Complete your profile".

13. **Empty Work List for job worker**
    - Show "Add the work".

14. **Empty Work Needed list for manufacturer**
    - Show "Find work by posting" / prompt user to post work needed.

15. **Loading state**
    - Show loading skeleton/cards while results are loading.

### Open Items From Round 9

- Resolve slight tension between global search and one-persona-at-a-time search: final UI likely uses one query with persona tabs and only one active result tab at a time.
- Decide whether cached saved item names/thumbnails can be shown offline even if opening requires internet.
- Decide exact empty-state text in simple English/Hindi/Gujarati later.
- Decide how long app waits before showing connection issue.
- Decide whether retry is automatic, manual, or both.

## Round 10: Final MVP Screen List and Priority

### Confirmed Answers

1. **Required MVP screens**
   - Splash.
   - Create Account / OTP.
   - Home.
   - Search.
   - Result List.
   - Profile Detail.
   - My Profile.
   - Edit Profile.
   - Add Work Card.
   - Add Work Needed Post.
   - Saved.
   - Notifications.
   - Report.
   - Admin later.

2. **Splash screen**
   - MVP should have a splash/logo screen.
   - Actual app logo/design will be decided later.

3. **Language**
   - MVP can be English only.
   - App should be built with translation structure for future Hindi/Gujarati support.

4. **Settings screen**
   - Settings screen should exist in MVP.
   - MVP settings should include:
     - notification settings
     - logout
     - contact support later
   - More settings can be added in future.

5. **Manufacturer My Posts**
   - Founder is thinking about a separate My Posts screen for manufacturers later.
   - For MVP, keep My Posts option inside My Profile.

6. **Job worker My Work**
   - Founder is thinking about a separate My Work screen for job workers later.
   - For MVP, keep My Work option inside My Profile.

7. **Skilled worker My Skills**
   - No separate My Skills screen in MVP.
   - Skilled worker/karigar uses My Profile edit.

8. **Admin-created seed profile marker**
   - Admin-created seed profile marker should be internal/admin only.
   - Do not show "added by admin" publicly to normal users.

9. **First 3 critical user journeys**
   - Manufacturer finds flat hemming job worker.
   - Job worker adds work card.
   - Manufacturer posts work needed.

10. **Deliberately postponed**
    - Voice search.
    - Map.
    - iOS.
    - Payments.
    - Ratings.

11. **Final app-flow spec**
    - Create final app-flow specification as a new Markdown file under `outputs/`.

12. **Next artifact after app-flow spec**
    - Create a detailed wireframe in Eraser / Eraser-style format.
    - Wireframe should be detailed and professional, as if a real company is designing the project carefully.
    - It should handle details with a sharp product/design eye.

13. **Screen-by-screen fields and buttons**
    - Include screen-by-screen fields and buttons in the wireframe.

14. **Mermaid flow diagrams**
    - Do not include Mermaid flow diagrams now.
    - Flow diagrams can be done later.

15. **MVP vs Later labels**
    - Do not label every screen/feature as MVP vs Later in the wireframe/spec unless needed.

### Open Items From Round 10

- Decide exact Settings menu content beyond notification settings, logout, and future support.
- Decide exact app logo/name later before visual design.
- Confirm whether final app-flow spec should be generated now before the Eraser-style wireframe.
- Check whether an Eraser MCP/tool is available before producing the next artifact; if unavailable, create an Eraser-ready Markdown/wireframe spec that can be pasted/imported manually.
