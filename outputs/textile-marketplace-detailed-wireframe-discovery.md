# Textile Marketplace Detailed Wireframe Discovery

Date: 2026-07-06
Status: In discovery
Purpose: Capture detailed screen-by-screen wireframe decisions before rebuilding the Figma wireframe.

## Source Context

Existing reference files:

- `outputs/textile-marketplace-app-flow-spec.md`
- `outputs/textile-marketplace-mid-fidelity-wireframe-spec.md`
- `outputs/eraser-mid-fidelity-wireframe-brief.md`

Current corrected onboarding decision:

`Create Account: name + mobile number -> OTP Verification -> Select Role -> Home`

Role options after OTP:

- Manufacturer / Business
- Job Worker / Value Adder
- Skilled Worker / Karigar

## Working Rules

- The assistant asks questions in rounds.
- Each round should avoid repeating already answered decisions.
- The user can answer by option letters/numbers or write a custom answer.
- After each user answer, append the answer and resolved decisions to this file.
- After enough rounds, convert this discovery file into a detailed Figma-ready wireframe specification.

## Round Log

## Round 1: App Opening + Account Flow

User answered on 2026-07-06.

### Answers

1. First screen after opening app for a new user:
   - Splash screen with app logo, app name, and a short tagline.
   - After splash, user goes to Create Account.

2. Create Account screen fields:
   - Name
   - Mobile number
   - After user enters the mobile number and continues, the OTP screen opens.

3. OTP screen:
   - OTP boxes
   - Verify button
   - Resend OTP action
   - Change mobile number action
   - Back button
   - Change mobile number and back both take the user back to the first account screen where name and mobile number are entered.

4. Select Role screen:
   - Three large cards.
   - Each card has an icon, role name, and short explanation.
   - Role options:
     - Manufacturer / Business
     - Job Worker / Value Adder
     - Skilled Worker / Karigar

5. Role selection confirmation:
   - User taps a role.
   - App shows confirmation text such as: `You selected Job Worker / Value Adder`.
   - User must confirm/continue before Home opens.

6. Wrong role / role change rule:
   - Once the user confirms the selected role and reaches Home, role cannot be changed.
   - The confirmation step exists so the user thinks carefully before entering Home.
   - Role can only be changed before final confirmation on the Select Role flow.

7. Home after role selection:
   - Top header has notification button at the top-right.
   - Main area shows three large cards asking what the user wants to find:
     - Find Manufacturer / Business
     - Find Job Worker / Value Adder
     - Find Skilled Worker / Karigar
   - Below those cards, show Complete Profile card.
   - Complete Profile card takes user to profile completion.
   - Footer bottom navigation has four buttons:
     - Home
     - Search
     - Saved
     - My Profile
   - App notifications are displayed from the notification button.

8. Explain that role does not limit search:
   - No.
   - Avoid extra explanation in the UI.

9. Temporary app name in wireframe:
   - `Connect`

10. Wireframe language:
   - English only.

### Resolved Flow

`Splash -> Create Account: name + mobile number -> OTP Verification -> Select Role -> Role Confirmation -> Home`

### Resolved Wireframe Decisions

- Create Account does not include role selection.
- Role selection happens after OTP verification.
- Role confirmation is mandatory before Home.
- Role is locked after confirmation and Home entry.
- Home always includes the three discovery cards, Complete Profile card, top-right notifications, and bottom navigation.

## Round 2: Home Screen Details

User answered on 2026-07-06.

### Answers

1. Home header layout:
   - Very top-left: app name `Connect`.
   - Very top-right: notification button.
   - Below header: greeting using the entered user name, such as `Hi, Aayush`.
   - Below greeting: main prompt `Who are you looking for?`.
   - Below prompt: three discovery cards.
   - After the discovery cards, leave some open breathing space.
   - Then show Complete Profile card.
   - Footer has bottom navigation with four buttons.

2. Main question text:
   - `Who are you looking for?`

3. Discovery card structure:
   - Icon
   - Title
   - One-line explanation

4. Manufacturer / Business card text:
   - `Find Manufacturers, Traders, Wholesalers`

5. Job Worker / Value Adder card text:
   - `Find Job worker, value adder`

6. Skilled Worker / Karigar card text:
   - `Find Skilled worker, Karigar`

7. Complete Profile card visibility:
   - Always show until profile is complete.

8. Complete Profile card text:
   - `Add your details and photos to get business`

9. Suggested popular searches on Home:
   - Yes.
   - Show popular searches such as:
     - Flat hemming
     - Digital print
     - Embroidery

10. Bottom navigation labels:
   - `Home`
   - `Search`
   - `Saved`
   - `My Profile`

### Resolved Home Wireframe Layout

Top-to-bottom Home structure:

1. Header row:
   - `Connect` at top-left.
   - Notification button at top-right.
2. Greeting:
   - `Hi, {user name}`
3. Main prompt:
   - `Who are you looking for?`
4. Discovery cards:
   - `Find Manufacturers, Traders, Wholesalers`
   - `Find Job worker, value adder`
   - `Find Skilled worker, Karigar`
5. Popular searches:
   - Flat hemming
   - Digital print
   - Embroidery
6. Spacing / breathing area.
7. Complete Profile card:
   - `Add your details and photos to get business`
8. Bottom navigation:
   - Home
   - Search
   - Saved
   - My Profile

### Notes For Future Wireframe

- Do not repeat account-flow questions unless a contradiction appears.
- Future questions should focus on wireframe structure, component anatomy, visible text, states, priority, and screen-level behavior.

## Wireframe Question Strategy

Added on 2026-07-06 after UX wireframing research.

Detailed wireframe rounds should ask about:

- Screen layout and visual hierarchy.
- Navigation and current-location cues.
- Component anatomy, such as cards, buttons, tabs, filters, forms, banners, and empty states.
- What information is visible immediately versus hidden until tap.
- Interaction states, including loading, empty, error, disabled, selected, confirmed, and pending.
- Low-digital-literacy clarity: large touch targets, plain labels, simple choices, and minimal explanation.
- Developer handoff detail: exact screen fields, card data, primary/secondary actions, and state rules.
- Prototype-testing tasks that the wireframe must support.

Research references used:

- Figma wireframing guide: wireframes align teams on screen layouts, navigation bars, UX/UI components, and interactive elements.
- Interaction Design Foundation: wireframes represent app/page structure and layout before detailed visual design.
- Nielsen Norman Group navigation guidance: users need clear cues for where they are in the interface.
- Nielsen Norman Group visual hierarchy guidance: hierarchy helps users know where to look and what is most important.
- Balsamiq and Maze wireframe-testing guidance: wireframes should be testable early to find usability issues before development.

## Round 3: Search Screen + Result List Wireframe Details

User answered on 2026-07-06.

### Answers

1. Screen opened after tapping a Home discovery card:
   - Open Search screen.
   - The selected persona option from Home should already be active.
   - Example:
     - If user taps Manufacturer / Business, Search opens with Manufacturer tab selected and recommended manufacturer/business profiles.
     - If user taps Job Worker / Value Adder, Search opens with Job Worker tab selected and recommended job workers.
     - If user taps Skilled Worker / Karigar, Search opens with Karigar tab selected and recommended karigars.
   - If user enters Search from footer bottom navigation, they can choose among tabs:
     - Manufacturers
     - Job Workers
     - Karigars
   - Search bar is empty by default.
   - Recommended profiles are shown until the user explicitly searches.

2. Job-worker screen title:
   - `Find Job Worker`

3. Job-worker search placeholder:
   - `Search work like flat hemming, embroidery etc`

4. Result tabs:
   - Yes.
   - Show tabs for:
     - Manufacturers
     - Job Workers
     - Karigars

5. Job-worker result card hierarchy:
   - Work photos first.
   - Then work name.
   - Then category of work.
   - Then product type.
   - Then job worker name.

6. Job-worker card image layout:
   - Photo carousel section.
   - Images automatically scroll horizontally from right to left.
   - Each image shows for around 2 seconds, then changes.

7. Job-worker card visible details:
   - Work photos.
   - Work name.
   - Category.
   - Product type.
   - Job worker name.
   - Verified blue tick if the job worker is verified.

8. Contact/address on result card:
   - No.
   - Never show contact number or address on result cards.

9. Filter button position:
   - Beside the search bar, on the right side.
   - Active filters can also appear as filter chips.

10. Filter sheet fields for job-worker search:
   - Category / work type.
   - Product type.
   - Locality.
   - Experience.
   - Verified only.
   - These filter options should remain flexible because user feedback may change them.

11. Sort options:
   - Show sort options.
   - Initial options:
     - Verified first.
     - Nearby.
     - Most photos.
     - Recently added.
   - Sort options should remain flexible because user feedback may change them.

12. Popular searches:
   - Show on Search screen before user types.

13. No-results state:
   - Show `Invite someone you know`.

14. Loading state:
   - Use skeleton result cards.

15. Spelling mistakes / local names:
   - Search should be highly accurate.
   - Show best matching results.
   - Also show suggestions under the search bar.

### Resolved Search Wireframe Layout

For Search opened from Home:

1. Header / top area:
   - Screen title based on selected persona, e.g. `Find Job Worker`.
   - Search bar.
   - Filter button on the right side of the search bar.
2. Persona tabs:
   - Manufacturers
   - Job Workers
   - Karigars
   - The tab matching the Home card is selected by default.
3. Before user types:
   - Show recommended profiles for the selected tab.
   - Show popular searches.
4. After user types:
   - Show best matching results.
   - Show suggestions under the search bar when relevant.
5. Results:
   - Use skeleton cards while loading.
   - Use carousel photo section on job-worker cards.
   - Do not show contact/address on result cards.
6. Filters:
   - Category/work type.
   - Product type.
   - Locality.
   - Experience.
   - Verified only.
7. Sort:
   - Verified first.
   - Nearby.
   - Most photos.
   - Recently added.
8. No results:
   - Show `Invite someone you know`.

### Notes For Future Wireframe

- Result cards should be designed as work-first cards, especially for job workers.
- The carousel should be shown visually in the wireframe, even if the actual animation is built later.
- Filter and sort controls should look flexible/modular because the exact set may change after user feedback.

## Round 4: Profile Detail Screen Wireframe Details

User answered on 2026-07-06.

### Answers

1. Job Worker result card tap:
   - Open Job Worker profile screen.
   - `Work List` tab is selected by default.
   - Show all work cards added by that job worker.
   - Beside/near `Work List`, show `Profile` / `View Profile` tab or button so the user can view full profile details.

2. Job Worker profile top area:
   - Show job worker name.
   - Show verified tick if verified.

3. Job Worker profile tabs:
   - `Work List`
   - `Profile`

4. Job Worker `Work List` cards:
   - Show all details the job worker added in the Add Work form.
   - Each work card should show:
     - Photo carousel.
     - Work name.
     - Category.
     - Product type.
     - Description.

5. Job Worker `Profile` tab:
   - Job worker name.
   - Workplace photos in carousel.
   - Work type(s) they do.
   - Locality.
   - Contact.
   - Address.
   - Additional fields may be added later based on user feedback.

6. Contact/action buttons on profile detail:
   - Call.
   - WhatsApp.
   - Save.
   - Share.
   - Report.

7. Contact/address visibility in MVP:
   - Show mobile number and full address directly in profile detail.

8. Manufacturer result card tap:
   - Open Manufacturer profile/detail screen.
   - `Work Needed` tab is selected by default.
   - Show all work-needed posts by that manufacturer/business.
   - Next tab is `Profile` / `View Profile`, showing business profile details.

9. Manufacturer `Work Needed` cards:
   - Photo carousel.
   - Work type.
   - Category.
   - Product type.
   - Description.

10. Manufacturer `Profile` tab:
   - Business name.
   - Business/shop photos in carousel.
   - What they manufacture/sell.
   - Contact.
   - Address.
   - Business category.

11. Karigar result tap:
   - Open simple profile detail screen.
   - No tabs required for MVP.

12. Karigar profile:
   - Name.
   - Photo.
   - Skill.
   - Experience.
   - Contact.
   - Address.

13. Similar profiles:
   - Show at the bottom of all profile detail screens.

14. Image gallery behavior:
   - Tapping any photo opens full-screen gallery.

15. Sticky action bar:
   - No sticky action bar.
   - Actions appear inside profile content.

### Resolved Profile Detail Wireframe Layouts

Job Worker profile:

1. Header:
   - Job worker name.
   - Verified tick if verified.
2. Tabs:
   - Work List.
   - Profile.
3. Default tab:
   - Work List.
4. Work List content:
   - Multiple work cards.
   - Each card has photo carousel, work name, category, product type, and description.
5. Profile tab:
   - Job worker name, workplace photo carousel, work types, locality, contact, address.
6. Actions:
   - Call, WhatsApp, Save, Share, Report.
7. Similar profiles:
   - Bottom of screen.

Manufacturer profile:

1. Header:
   - Business name.
   - Verified tick if verified.
2. Tabs:
   - Work Needed.
   - Profile.
3. Default tab:
   - Work Needed.
4. Work Needed content:
   - Multiple work-needed post cards.
   - Each card has photo carousel, work type, category, product type, and description.
5. Profile tab:
   - Business name, shop photo carousel, what they manufacture/sell, contact, address, business category.
6. Actions:
   - Call, WhatsApp, Save, Share, Report.
7. Similar profiles:
   - Bottom of screen.

Karigar profile:

1. Simple profile detail screen.
2. Show name, photo, skill, experience, contact, and address.
3. Actions:
   - Call, WhatsApp, Save, Share, Report.
4. Similar profiles:
   - Bottom of screen.

### Notes For Future Wireframe

- Use carousel indicators on work, workplace, shop, and work-needed photos.
- Keep action buttons inside content, not as a sticky bottom bar.
- Contact reveal is direct in MVP profile details, but still not shown on result cards.

## Round 5: My Profile + Profile Completion Wireframe Details

User answered on 2026-07-06.

Status: Complete.

### Answers

1. My Profile before profile completion:
   - Show dashboard card with completion percentage and `Complete Profile` button.

2. My Profile top card:
   - Show name.
   - Show role.
   - Show mobile number.
   - Show completion percentage.

3. Profile completion entry button text:
   - `Complete your profile to get business`

4. Profile completion form style:
   - Step-by-step screens.

5. Manufacturer profile completion required fields:
   - Business name.
   - Manufacture/sell detail.
   - Category.
   - Product type.
   - Owner name.
   - Shop photos.
   - Address.

6. Job Worker profile completion required fields:
   - Workshop name.
   - Photos of workplace.
   - Owner name.
   - Type of work they do.
   - Category.
   - Product type.
   - Address.

7. Karigar profile completion required fields:
   - Name.
   - Skill.
   - Experience.
   - Photo.
   - Contact.
   - Address.

8. Photo upload UI for profile completion:
   - One upload button.
   - Uploaded photo grid.

9. Save incomplete profile:
   - Auto-save.
   - Also show `Save and exit`.

10. After completing required profile fields:
   - Show both:
     - Done.
     - Submit Verification button.

11. My Profile actions/layout for Job Worker:
   - At the top, show a tab bar with:
     - Work List.
     - My Profile.
   - Work List tab shows all work cards added by the user.
   - Sticky bottom-right add button to add new work.

12. My Profile actions/layout for Manufacturer:
   - At the top, show a tab bar with:
     - Work Needed Posts.
     - My Profile.
   - Work Needed Posts tab shows all work-needed posts added by the user.
   - Sticky bottom-right add button to add a new work-needed post.

13. Hide from search toggle:
   - Put inside Settings.

14. Verification status on My Profile:
   - Show only after user submits verification.

15. Profile completion reminders:
   - Show one short tip card only.

### Resolved My Profile Wireframe Decisions

General My Profile before completion:

1. Dashboard card shows:
   - Name.
   - Role.
   - Mobile number.
   - Completion percentage.
   - Button: `Complete your profile to get business`.
2. Profile completion is step-by-step.
3. Save behavior:
   - Auto-save progress.
   - Also provide `Save and exit`.
4. After required fields are complete:
   - Show `Done`.
   - Show `Submit Verification`.
5. Verification status:
   - Do not show before submission.
   - Show only after user submits verification.
6. Hide from search:
   - Put inside Settings.
7. Reminders:
   - One short tip card only.

Manufacturer profile completion fields:

- Business name.
- Manufacture/sell detail.
- Category.
- Product type.
- Owner name.
- Shop photos.
- Address.

Job Worker profile completion fields:

- Workshop name.
- Workplace photos.
- Owner name.
- Type of work they do.
- Category.
- Product type.
- Address.

Karigar profile completion fields:

- Name.
- Skill.
- Experience.
- Photo.
- Contact.
- Address.

Owner view for Job Worker:

- Top tab bar:
  - Work List.
  - My Profile.
- Work List tab shows all user-added work cards.
- Sticky bottom-right add button adds work.

Owner view for Manufacturer:

- Top tab bar:
  - Work Needed Posts.
  - My Profile.
- Work Needed Posts tab shows all user-added work-needed posts.
- Sticky bottom-right add button adds work-needed post.

### Notes For Future Wireframe

- Owner-side tab layout is different from visitor profile layout but uses similar labels.
- Sticky add button is only for owner creation screens, not public profile detail screens.
- Do not show hide-from-search on My Profile main page; put it in Settings.

## Round 6: Add Work Card + Add Work Needed Post Wireframe Details

User answered on 2026-07-07.

### Answers

1. Job Worker `Add Work` entry point:
   - Sticky bottom-right `+` button on the Work List tab.

2. Add Work form style:
   - One long form.

3. Add Work field order:
   - Category first.
   - Work name.
   - Product type.
   - Photos.

4. If category/work name is not available:
   - Show `Other` option.
   - Show text field for custom entry.

5. Add Work photo requirement:
   - Minimum 3 photos.

6. Add Work photo UI:
   - Upload button.
   - Uploaded photo grid.

7. Add Work submit button text:
   - `Save and Publish`

8. After Job Worker publishes work card:
   - Return to Work List.
   - Show the newly added work card in the list.

9. Manufacturer `Add Work Needed` entry point:
   - Sticky bottom-right `+` button on Work Needed Posts tab.

10. Add Work Needed form style:
   - One long form.

11. Add Work Needed field order:
   - Category first.
   - Name of the work.
   - Product type.
   - Photos.

12. Add Work Needed photo requirement:
   - Minimum 3 photos.

13. Add Work Needed status on publish:
   - Always publish as Active.

14. Add Work Needed submit button text:
   - `Save and Publish`

15. After Manufacturer publishes work-needed post:
   - Return to Work Needed Posts list.
   - Show the newly added post in the list.

### Resolved Add Work Card Wireframe

Entry:

- Job Worker owner view.
- Work List tab.
- Sticky bottom-right `+` button.

Form:

1. Category.
2. Work name.
3. Product type.
4. Photo upload.
5. Uploaded photo grid.
6. Description / other fields from existing Add Work form.
7. Submit button: `Save and Publish`.

Rules:

- Minimum 3 photos.
- If category or work name is missing, user can choose `Other` and type a custom value.
- On publish, return to Work List and show new work card.

### Resolved Add Work Needed Wireframe

Entry:

- Manufacturer owner view.
- Work Needed Posts tab.
- Sticky bottom-right `+` button.

Form:

1. Category.
2. Name of the work.
3. Product type.
4. Photo upload.
5. Uploaded photo grid.
6. Description / other fields from existing Add Work Needed form.
7. Submit button: `Save and Publish`.

Rules:

- Minimum 3 photos.
- Publish status is always Active.
- On publish, return to Work Needed Posts list and show new post.

### Notes For Future Wireframe

- Both owner creation forms use one long form, not step-by-step.
- Profile completion uses step-by-step screens, but Add Work and Add Work Needed use long forms.
- Minimum photo requirement changed to 3 photos for both Add Work and Add Work Needed.
- Sticky `+` button belongs on owner list tabs only.

## Round 7: Verification Flow Wireframe Details

User answered on 2026-07-07.

### Answers

1. Where `Submit Verification` / verification action appears:
   - Only after profile completion screen.
   - Also appears in the My Profile tab/action area.

2. Verification button enabled:
   - Only after required profile fields are complete.

3. Before eligible for verification:
   - Show message: `Complete profile first`.

4. Verification screen/form:
   - After adding all profile details, the last profile completion step shows two buttons:
     - Save.
     - Verify and Save.

5. Verification submission includes:
   - Profile details.
   - Photos.
   - Optional ID proof.
   - Optional GST proof for business/job worker.

6. Manufacturer verification uploads/data:
   - Profile details.
   - Shop photos.
   - Optional ID proof.
   - Optional GST proof.

7. Job Worker verification uploads/data:
   - Profile details.
   - Shop photos.
   - Optional ID proof.
   - Optional GST proof.

8. Karigar verification uploads/data:
   - Profile details.
   - Skill details.
   - Optional ID proof.

9. After user submits verification:
   - Show `Pending review` status on My Profile.

10. While verification is pending:
   - Profile editing is locked.

11. If verification is approved:
   - Show approved status on My Profile.
   - Show blue tick publicly.

12. If changes requested:
   - Show message in Notifications.

13. Public verification details:
   - Public users see only blue tick.
   - Do not show verification details publicly.

14. Verification status card/badge design:
   - Small badge near completion percentage.

15. Verification CTA text:
   - `Verify My Profile`

### Resolved Verification Wireframe

Eligibility:

- Verification is enabled only when required profile fields are complete.
- Before eligibility, show `Complete profile first`.

Profile completion final step:

- Show two actions:
  - Save.
  - Verify and Save / Verify My Profile.

My Profile:

- Show verification action in My Profile tab/action area.
- Show verification status only after submission.
- Status badge appears near completion percentage.

Submission data:

- Manufacturer:
  - Profile details, shop photos, optional ID proof, optional GST proof.
- Job Worker:
  - Profile details, shop photos, optional ID proof, optional GST proof.
- Karigar:
  - Profile details, skill details, optional ID proof.

States:

- Pending review:
  - Show on My Profile.
  - Lock profile editing.
- Approved:
  - Show approved status on My Profile.
  - Show blue tick publicly.
- Changes requested:
  - Show message in Notifications.

Public display:

- Only blue tick is visible publicly.
- No public verification detail breakdown.

### Notes For Future Wireframe

- The final profile completion screen must show Save and Verify actions clearly.
- Use `Verify My Profile` as primary CTA text.
- Pending review should make edit controls look locked/disabled.
- Changes requested should be represented in Notifications and also may be linked from My Profile if needed later.

## Round 8: Saved, Share, Report, Notifications, and Settings Wireframe Details

User answered on 2026-07-07.

### Answers

1. Saved screen grouping:
   - At the top, show tabs.
   - Tabs/buttons:
     - Business.
     - Job Worker.
     - Karigar.

2. Saved item card:
   - Use the same card style as search results.
   - Add a remove button.

3. Save action feedback:
   - The Save button changes to `Saved`.

4. Share button placement:
   - Only on profile detail.
   - Put share icon/logo in the top-right header.

5. Share sheet options:
   - Copy link.
   - WhatsApp.
   - SMS.
   - X.
   - Email.
   - LinkedIn.
   - Also support all apps where sharing is possible through the native share sheet.

6. Report button placement:
   - Only on profile detail.
   - Put it inside the top-right three-dot menu.

7. Report reasons:
   - Wrong contact.
   - Wrong category.
   - Inappropriate photo.
   - Wrong details.

8. Report optional text box:
   - No.

9. After report submit:
   - Return to previous screen.
   - Show toast confirmation.

10. Notifications screen:
   - Simple list of notifications.

11. Notification card layout:
   - Title.
   - Short message.
   - Date/time.

12. Settings MVP items:
   - Notification settings.
   - Logout.
   - Contact support.
   - Hide from search.

13. Hide from search control:
   - Toggle with warning text.

14. Logout confirmation:
   - No confirmation.

15. Contact support:
   - WhatsApp/call support button.

### Resolved Saved Wireframe

Saved screen:

1. Header:
   - Title: `Saved`.
2. Top tabs:
   - Business.
   - Job Worker.
   - Karigar.
3. Saved cards:
   - Same visual structure as search result cards.
   - Include remove button.
4. Save state:
   - Saved profile/detail action changes from Save to `Saved`.

### Resolved Share and Report Wireframe

Profile detail header:

- Top-right share icon.
- Top-right three-dot menu.

Share:

- Available only on profile detail.
- Opens native share options with copy link, WhatsApp, SMS, X, email, LinkedIn, and other available apps.

Report:

- Available only from profile detail three-dot menu.
- Report reasons:
  - Wrong contact.
  - Wrong category.
  - Inappropriate photo.
  - Wrong details.
- No optional text box.
- On submit, return to previous screen and show toast.

### Resolved Notifications Wireframe

Notifications screen:

1. Header:
   - Title: `Notifications`.
2. Content:
   - Simple list.
3. Notification row/card:
   - Title.
   - Short message.
   - Date/time.

### Resolved Settings Wireframe

Settings screen MVP items:

- Notification settings.
- Hide from search.
- Contact support.
- Logout.

Hide from search:

- Toggle.
- Warning text explaining that hidden profiles will not appear in search.

Contact support:

- WhatsApp/call support button.

Logout:

- No confirmation.

### Notes For Future Wireframe

- Do not ask these Saved/Share/Report/Notifications/Settings placement questions again unless the user changes the scope.
- Share and report are profile-detail-only actions.
- Result cards never carry share/report actions in MVP.
- Remaining discovery rounds should focus on visual hierarchy, exact screen states, form validation, prototype paths, and Figma handoff details that are not yet decided.

## Round 9: Empty States, Validation States, Permissions, and Error Handling

User answered on 2026-07-07.

### Answers

1. Create Account empty-name error:
   - `Please enter the name`

2. Create Account invalid/incomplete mobile number error:
   - `Please enter the mobile number`

3. Wrong OTP error:
   - `Incorrect OTP`

4. Role selection confirmation layout:
   - Full screen.

5. Search no-results state:
   - Show only:
     - `Invite someone you know`
     - Button to share app information through the user's selected app.

6. Empty recommended profiles state before searching:
   - `Search for profile/work`

7. No results after applying filters:
   - Show `Clear filters` button.

8. Photo upload validation when user gives fewer than 3 photos:
   - `Minimum 3 photos required`

9. Photo upload failure because of poor internet:
   - `Unable to upload, please retry`

10. Photo/gallery permission denied:
   - `Permission required`

11. Saved screen empty state:
   - `No saved profiles`

12. Notifications empty state:
   - `No notifications`

13. Verification pending profile-edit lock:
   - Show edit buttons disabled.

14. Full-screen photo gallery controls:
   - Close.
   - Next/previous.
   - Image count.

15. Hide from search ON state:
   - My Profile should show a visible warning badge.

16. Additional general network error state:
   - `Can't access internet`

### Resolved Validation and Error Wireframe

Account creation:

- Empty name:
  - Inline error: `Please enter the name`.
- Missing/incomplete mobile:
  - Inline error: `Please enter the mobile number`.

OTP:

- Wrong OTP:
  - Inline or toast error: `Incorrect OTP`.

Role confirmation:

- Use a full-screen confirmation step after role card tap.
- User reaches Home only after confirming.

Search empty/error states:

- No search results:
  - Show `Invite someone you know`.
  - Show share/invite button.
- Recommended profiles empty:
  - Show `Search for profile/work`.
- Filtered results empty:
  - Show `Clear filters` button.
- General network failure:
  - Show `Can't access internet`.

Upload and permissions:

- Less than 3 photos:
  - Show `Minimum 3 photos required`.
- Upload failure:
  - Show `Unable to upload, please retry`.
- Permission denied:
  - Show `Permission required`.

Saved:

- Empty state text:
  - `No saved profiles`.

Notifications:

- Empty state text:
  - `No notifications`.

Verification locked state:

- While verification is pending:
  - Keep edit buttons visible but disabled.

Full-screen gallery:

- Controls:
  - Close.
  - Next/previous.
  - Image count.

Hidden profile state:

- If Hide from Search is ON:
  - Show a visible warning badge on My Profile.

### Notes For Future Wireframe

- Use exact short error text in the wireframe.
- Keep empty states plain and action-oriented.
- Do not add extra explanatory copy around no-results states unless the user asks later.
- Remaining questions should focus on Figma layout fidelity, visual hierarchy, screen coverage, and prototype linking.

## Round 10: Figma Wireframe Layout, Fidelity, and Annotation Rules

User answered on 2026-07-07.

### Answers

1. Mobile frame size:
   - The app should eventually work on any screen size.
   - For the current wireframe, use `360 x 800`.

2. Wireframe style:
   - More realistic UI with soft colors.

3. Screen annotations:
   - Add annotations only for complex screens.

4. User-flow arrows:
   - Show arrows between all connected screens.

5. Figma canvas organization:
   - One big canvas.
   - All screens grouped by flow.

6. Screen header style:
   - Use the same header pattern across the app.
   - Header should support back/action layout.

7. Bottom navigation visibility:
   - Show bottom navigation only on:
     - Home.
     - Saved.
     - My Profile.

8. Profile-completion form progress:
   - Use progress bar.

9. Form field style:
   - Label above input.
   - Placeholder inside input.

10. Photo carousel representation:
   - One large image.
   - Small dots.

11. Result card size/style:
   - Large photo-first card.
   - Details below inside the card.

12. State variants:
   - Include state variants as mini screens:
     - Loading.
     - Empty.
     - Error.
     - Permission.
     - Validation.

13. Admin screens:
   - No admin screens in this wireframe.

14. Prototype journeys:
   - Connect only the 3 main journeys.

15. Final output sequence:
   - Create the detailed Markdown wireframe spec first.
   - Figma rebuild comes after the spec.

### Resolved Figma Production Rules

Frame and responsive assumption:

- Primary mobile frame: `360 x 800`.
- Design should still be conceptually responsive for other Android screen sizes later.

Visual fidelity:

- Use mid-fidelity, realistic mobile UI.
- Use soft colors, not grayscale-only wireframes.
- Still keep the design focused on structure and flows, not final branding polish.

Canvas organization:

- One big Figma canvas.
- Screens grouped by flow.
- Show arrows between connected screens.

Annotations:

- Add annotations only for complex screens, such as:
  - Search and filters.
  - Profile detail tabs.
  - My Profile owner views.
  - Verification locked/pending state.
  - Add Work / Add Work Needed forms.

Navigation:

- Use a consistent app header with back/action support.
- Bottom navigation appears only on:
  - Home.
  - Saved.
  - My Profile.
- Search opened from Home can avoid bottom navigation if the flow requires focus, unless reused as a tab destination later.

Forms:

- Profile completion forms use progress bar.
- Inputs use label above field and placeholder inside.

Cards and media:

- Photo carousel is represented as one large image with small dots.
- Result cards are large, photo-first cards with details below.

State variants:

- Include mini screens for:
  - Loading.
  - Empty.
  - Error.
  - Permission denied.
  - Validation errors.

Scope:

- No admin screens in this wireframe.
- Prototype links should cover only the 3 main journeys.
- First create the detailed Markdown wireframe spec; only then rebuild Figma.

### Notes For Spec Creation

- This completes the discovery rounds for the detailed wireframe.
- The next artifact should be a Figma-ready Markdown spec generated from this discovery file.
- The spec should be detailed enough to rebuild the Figma file without guessing screen structure, component content, or flow connections.
