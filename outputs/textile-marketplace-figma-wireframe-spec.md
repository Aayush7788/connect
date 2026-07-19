# Textile Marketplace Figma Wireframe Spec

Date: 2026-07-08
Status: Ready for Figma build after final human review
Source: `outputs/textile-marketplace-detailed-wireframe-discovery.md`

This document is the Figma-ready wireframe specification for the Android MVP. It converts the detailed discovery rounds into a buildable Figma plan. The goal is a mid-fidelity, realistic, editable mobile wireframe board that a product/design/Flutter team can inspect without needing to re-read the discovery conversation.

## 1. Product Frame

Product name in wireframe: `Connect`

Primary user context:

- Surat-first textile marketplace.
- Android-only MVP.
- English-only UI for this wireframe.
- Future translation structure is expected, but do not show Gujarati/Hindi UI in this wireframe.
- Users have low to mixed digital literacy, so screens must use large touch targets, simple words, obvious actions, and minimal explanatory text.

Core marketplace roles:

- Manufacturer / Business.
- Job Worker / Value Adder.
- Skilled Worker / Karigar.

Important rule:

- A user's own selected role controls profile-completion forms, but it does not limit what the user can search.
- Do not explain this rule inside the UI; keep UI simple.

## 2. Figma Output Standard

Frame size:

- Primary screen size: `360 x 800`.
- All mobile frames should use this size.
- Keep components responsive in spirit, but optimize the wireframe for this size.

Fidelity:

- Mid-fidelity.
- Realistic mobile UI.
- Soft colors, not grayscale-only.
- Not final branding.
- Use image placeholders and carousel indicators instead of real textile photos unless image assets are explicitly added later.

Visual tone:

- Practical, trust-focused, work-marketplace feel.
- Avoid landing-page or marketing composition.
- Avoid decorative background blobs, gradients, or ornamental visuals.
- Use simple icon placeholders where needed.

Canvas organization:

- One big Figma canvas.
- Screens grouped by flow sections.
- Show arrows between connected screens.
- Add annotations only for complex screens.

Recommended section layout on canvas:

1. `01 Entry and Role Lock`
2. `02 Home and Persona Search`
3. `03 Result Cards and Profile Details`
4. `04 My Profile and Profile Completion`
5. `05 Add Work and Work Needed`
6. `06 Verification States`
7. `07 Saved Share Report Notifications Settings`
8. `08 State Variants`
9. `09 Critical Prototype Journeys`

## 3. Global UI Rules

### 3.1 Header Pattern

Use the same header pattern across app screens.

Default header variants:

1. Root header:
   - Left: `Connect` or screen title.
   - Right: notification bell or relevant action.

2. Detail header:
   - Left: back arrow.
   - Center/left title.
   - Right: share icon and three-dot menu if profile detail.

3. Form header:
   - Left: back arrow.
   - Title: form name.
   - Optional right action only if required.

Header height guidance:

- Top safe area plus header: approximately 64 px.
- Keep title readable and avoid crowding right-side actions.

### 3.2 Bottom Navigation

Bottom navigation is role-specific:

- Manufacturer/business: `Home`, `Add Post`, `Saved`, `My Profile`.
- Job worker/value adder: `Home`, `Add Work`, `Saved`, `My Profile`.
- Skilled worker/karigar: `Home`, `Saved`, `My Profile`.

Behavior:

- Search is not a bottom-navigation destination. A user enters Search only by selecting one of the three discovery cards on Home.
- `Add Post` opens the manufacturer's dedicated Work Needed Posts owner screen, which retains its sticky `+` button.
- `Add Work` opens the job worker's dedicated Work List owner screen, which retains its sticky `+` button.
- `My Profile` is profile-only and must not contain Work Needed Posts or Work List tabs.
- The focused Search screen does not show bottom navigation.

### 3.3 Buttons

Primary buttons:

- Full-width for form submission.
- Minimum height: 44-48 px.
- Strong filled color.

Secondary buttons:

- Outline or soft fill.
- Used for `Save and exit`, `Change mobile number`, `Clear filters`, etc.

Icon actions:

- Call.
- WhatsApp.
- Save / Saved.
- Share.
- Report through three-dot menu.
- Notification bell.
- Back.
- Close gallery.

Use labels with icons where the action may be unclear for low-digital-literacy users.

### 3.4 Cards

All cards:

- Rounded rectangle, modest radius.
- Clear border or subtle shadow.
- Avoid cards inside cards.
- Use generous spacing.

Result cards:

- Large photo-first card.
- Details below the image.
- Never show contact number or address on result cards.

### 3.5 Photo Carousel Representation

Use:

- One large image placeholder.
- Small dot indicators.
- Optional mini label such as `1/5` only in gallery/detail contexts.

Do not represent auto-scroll as animation in the static wireframe. Add annotation on search result card:

`Carousel auto-scrolls in app; wireframe shows first image state.`

### 3.6 Forms

Profile completion:

- Step-by-step screens.
- Progress bar at top.
- Label above input.
- Placeholder inside input.
- Auto-save behavior should be represented by small status text or annotation, not excessive copy.

Add Work / Add Work Needed:

- One long form.
- Not step-by-step.

Validation:

- Show short inline error text exactly as specified.

### 3.7 Scrolling

- A screen scrolls only when its visible content exceeds the available viewport.
- Short screens stop at their final visible element and must not expose blank scroll space below it.
- Hidden bottom-navigation tabs must not determine the selected tab's scroll extent.
- Long forms and lists retain normal content-bounded scrolling, keyboard avoidance, and safe-area padding.

## 4. Screen Inventory

Create these mobile frames.

### 4.1 Entry Flow

1. `01.01 Splash`
2. `01.02 Create Account`
3. `01.03 Create Account - Validation`
4. `01.04 OTP Verification`
5. `01.05 OTP Verification - Error`
6. `01.06 Select Role`
7. `01.07 Role Confirmation`

### 4.2 Home And Search

8. `02.01 Home - Incomplete Profile`
9. `02.02 Search - Fixed Target From Home`
10. `02.03 Search - Job Worker Recommended`
11. `02.04 Search - Job Worker Query`
12. `02.05 Filter Sheet`
13. `02.06 Search - No Results`
14. `02.07 Search - Empty Recommended`

### 4.3 Profile Details

15. `03.01 Job Worker Detail - Work List`
16. `03.02 Job Worker Detail - Profile`
17. `03.03 Manufacturer Detail - Work Needed`
18. `03.04 Manufacturer Detail - Profile`
19. `03.05 Karigar Detail`
20. `03.06 Full Screen Gallery`

### 4.4 My Profile And Completion

21. `04.01 My Profile - Incomplete`
22. `04.02 Complete Profile - Business Step`
23. `04.03 Complete Profile - Job Worker Step`
24. `04.04 Complete Profile - Karigar Step`
25. `04.05 Complete Profile - Photo Upload`
26. `04.06 Complete Profile - Final Actions`
27. `04.07 Job Worker Owner Work List`
28. `04.08 Manufacturer Owner Work Needed`
29. `04.09 My Profile - Owner Profile Tab`

### 4.5 Add Work And Work Needed

30. `05.01 Add Work Card`
31. `05.02 Add Work Card - Other Custom`
32. `05.03 Add Work Card - Photo Validation`
33. `05.04 Add Work Needed Post`
34. `05.05 Add Work Needed - Published`

### 4.6 Verification

35. `06.01 Verification Not Eligible`
36. `06.02 Verification Submit Ready`
37. `06.03 Verification Pending - Locked`
38. `06.04 Verification Approved`
39. `06.05 Verification Changes Requested Notification`
40. `06.06 Verification Changes Requested - Resubmit`

### 4.7 Saved, Share, Report, Notifications, Settings

41. `07.01 Saved`
42. `07.02 Saved - Empty`
43. `07.03 Share Sheet`
44. `07.04 Report Reason Sheet`
45. `07.05 Report Submitted Toast`
46. `07.06 Notifications`
47. `07.07 Notifications - Empty`
48. `07.08 Settings`
49. `07.09 Settings - Hide From Search On`

### 4.8 State Variants

50. `08.01 Loading Skeleton`
51. `08.02 Network Error`
52. `08.03 Permission Required`
53. `08.04 Upload Failed`

### 4.9 Critical Journeys

54. `09.01 Journey - Manufacturer Finds Flat Hemming Job Worker`
55. `09.02 Journey - Job Worker Adds Work Card`
56. `09.03 Journey - Manufacturer Posts Work Needed`

If Figma attempt limits require fewer frames, keep frames 1-49 and represent frames 50-56 as compact annotation strips instead of full phone frames. Do not remove the three critical journeys entirely.

## 5. Entry Flow Screens

### 5.1 `01.01 Splash`

Purpose:

- Brand entry before account creation.

Layout:

- Center logo placeholder.
- App name: `Connect`.
- Short tagline placeholder under name.
- Small loading indicator near bottom.

Visible text:

- `Connect`
- `Textile work connections`

Arrow:

- Splash -> Create Account.

### 5.2 `01.02 Create Account`

Purpose:

- New user enters name and mobile before OTP.

Layout:

- Header: `Create account`.
- Form fields:
  - Label: `Name`
  - Placeholder: `Enter your name`
  - Label: `Mobile number`
  - Placeholder: `Enter mobile number`
- Primary button: `Continue`

Rules:

- No role selection here.
- No search before account creation.
- Continue opens OTP Verification.

### 5.3 `01.03 Create Account - Validation`

Purpose:

- Show exact validation messages.

Use same layout as Create Account.

Validation states:

- Under Name: `Please enter the name`
- Under Mobile number: `Please enter the mobile number`

### 5.4 `01.04 OTP Verification`

Purpose:

- Verify mobile OTP.

Layout:

- Header with back arrow.
- Title: `Enter OTP`
- Supporting text: `Code sent to {mobile number}`
- OTP boxes: 4 or 6 boxes, depending on final OTP provider; wireframe can show 6.
- Primary button: `Verify`
- Text actions:
  - `Resend OTP`
  - `Change mobile number`

Back behavior:

- Back and Change mobile number both return to Create Account.

### 5.5 `01.05 OTP Verification - Error`

Same as OTP screen with error:

- `Incorrect OTP`

### 5.6 `01.06 Select Role`

Purpose:

- User selects profile role after OTP succeeds.

Layout:

- Header: `Select your role`
- Short prompt: `What describes you?`
- Three large cards:
  1. Icon placeholder + `Manufacturer / Business` + one-line explanation.
  2. Icon placeholder + `Job Worker / Value Adder` + one-line explanation.
  3. Icon placeholder + `Skilled Worker / Karigar` + one-line explanation.

Card explanation copy:

- Manufacturer / Business: `I make or sell textile products`
- Job Worker / Value Adder: `I do textile work for others`
- Skilled Worker / Karigar: `I am an individual skilled worker`

Rule:

- Tapping a role does not go directly to Home.
- It opens full-screen confirmation.

### 5.7 `01.07 Role Confirmation`

Purpose:

- Prevent wrong role selection.

Layout:

- Full-screen confirmation.
- Large selected role icon.
- Text: `You selected Job Worker / Value Adder`
- Primary button: `Continue`
- Secondary/back action: `Change role`

Rules:

- Continue saves role and opens Home.
- Change role returns to Select Role.
- After Home entry and profile completion, role cannot be changed.

## 6. Home And Search Screens

### 6.1 `02.01 Home - Incomplete Profile`

Purpose:

- Main discovery hub for all roles.

Layout top to bottom:

1. Header:
   - Left: `Connect`
   - Right: notification bell.
2. Greeting:
   - `Hi, Aayush`
3. Prompt:
   - `Who are you looking for?`
4. Three discovery cards:
   - `Find Manufacturers, Traders, Wholesalers`
   - `Find Job worker, value adder`
   - `Find Skilled worker, Karigar`
5. Complete Profile card when the profile is incomplete:
   - `Add your details and photos to get business`
   - Button: `Complete Profile`
6. Bottom nav:
   - Home selected.
   - Manufacturer/business: Add Post.
   - Job worker/value adder: Add Work.
   - Saved.
   - My Profile.

For skilled worker/karigar, show only Home, Saved, and My Profile.

Arrows:

- Manufacturer card -> fixed-target Business Search with Work Needed selected by default.
- Job Worker card -> fixed-target Job Worker Search with Work selected by default.
- Karigar card -> fixed-target Karigar Search without secondary tabs.
- Complete Profile -> relevant profile completion flow.
- Notification bell -> Notifications.

### 6.2 `02.02 Search - Fixed Target From Home`

Purpose:

- Search screen opened only from one of the three Home discovery cards.

Layout:

1. Header:
   - Back arrow or simple title area.
   - Title: `Search`
2. Search row:
   - Placeholder: `Search for profile/work`
   - Filter button on right.
3. Optional mode tabs determined by the fixed target:
   - Business: `Work Needed` and `Profiles`.
   - Job Worker: `Work` and `Profiles`.
   - Karigar: no secondary tabs.
4. Before user searches:
   - Recommended profiles for the selected/default tab.
   - Popular searches.

Default selected mode:

- Business Search defaults to `Work Needed`.
- Job Worker Search defaults to `Work`.
- The user must return Home to select another persona target.

Bottom navigation:

- Do not draw bottom navigation on this Search screen; it is a focused search destination.

### 6.3 `02.03 Search - Job Worker Recommended`

Purpose:

- Search screen opened from Home after tapping Job Worker.

Layout:

1. Header:
   - Back arrow.
   - Title: `Find Job Worker`
2. Search row:
   - Search input placeholder: `Search work like flat hemming, embroidery etc`
   - Filter button on right.
3. Mode tabs:
   - `Work` selected.
   - `Profiles`.
4. Popular searches:
   - `Flat hemming`, `Digital print`, `Embroidery`
5. Recommended results list.

Job-worker recommended card anatomy:

- Large photo carousel placeholder with dots.
- Work name: `Flat hemming`
- Category: `Stitching`
- Product type: `Dupatta`
- Job worker name: `Ravi Hemming Works`
- Verified blue tick if verified.

Do not show:

- Contact number.
- Address.

Annotation:

- Recommended results appear before user types.
- Carousel auto-scrolls in app.

### 6.4 `02.04 Search - Job Worker Query`

Purpose:

- Search after user types a query.

Search input value:

- `flat hemming`

Below search row:

- Suggestions line: `Showing best matches for flat hemming`

Results:

- 2-3 job-worker cards.
- First card should look strong and verified.
- Cards use the same work-first anatomy.

Sort row:

- Show current sort chip: `Verified first`
- Optional sort button/chip: `Sort`

### 6.5 `02.05 Filter Sheet`

Purpose:

- Modular filter controls.

Display:

- Bottom sheet or overlaid panel next to Search screen.

Fields:

- Category / work type.
- Product type.
- Locality.
- Experience.
- Verified only toggle.

Actions:

- `Apply`
- `Clear filters`

Annotation:

- Filter options are flexible and may change after user feedback.

### 6.6 `02.06 Search - No Results`

Purpose:

- No results after query or filters.

Layout:

- Empty-state icon placeholder.
- Text: `Invite someone you know`
- Button: `Share app`
- If filters active, also show button: `Clear filters`

Do not add extra explanatory text.

### 6.7 `02.07 Search - Empty Recommended`

Purpose:

- No recommended profiles before search.

Text:

- `Search for profile/work`

## 7. Result Card Specifications

### 7.1 Manufacturer / Business Result Card

Card content:

- Large photo carousel placeholder showing product/work photo.
- Business name.
- Verified tick if verified.
- Category chip.
- Business/work type.
- Locality if space permits.

Tap behavior:

- Opens Manufacturer Detail with Work Needed selected.

Never show:

- Contact number.
- Full address.

### 7.2 Job Worker / Value Adder Result Card

Card content order:

1. Work photos first.
2. Work name.
3. Category of work.
4. Product type.
5. Job worker name.
6. Verified tick if verified.

Tap behavior:

- Opens Job Worker Detail with Work List selected.

Never show:

- Contact number.
- Full address.

### 7.3 Skilled Worker / Karigar Result Card

Card content:

- Worker photo placeholder.
- Name.
- Work/skill.
- Experience.
- Locality if space permits.
- Verified tick if verified.

Tap behavior:

- Opens Karigar Detail.

Never show:

- Contact number.
- Full address.

## 8. Profile Detail Screens

Global profile detail rules:

- Profile detail can show contact number and full address in MVP.
- Later this becomes a Show Contact button, but do not design paid locking now.
- Public users see only blue tick, not verification breakdown.
- Actions appear inside profile content, not as a sticky bottom bar.
- Similar profiles appear at the bottom of detail screens.
- Share icon appears in the header top-right.
- Report is inside top-right three-dot menu.

### 8.1 `03.01 Job Worker Detail - Work List`

Header:

- Back arrow.
- Job worker name.
- Verified tick if verified.
- Right: share icon, three-dot menu.

Tabs:

- `Work List` selected.
- `Profile`.

Content:

- Work card list.
- Each work card:
  - Photo carousel with dots.
  - Work name.
  - Category.
  - Product type.
  - Description.

Actions inside content:

- Call.
- WhatsApp.
- Save.

Note:

- Share and report remain in header actions.

### 8.2 `03.02 Job Worker Detail - Profile`

Header same as job-worker detail.

Tabs:

- `Work List`
- `Profile` selected.

Content:

- Workplace photo carousel.
- Job worker/workshop name.
- Work types they do.
- Locality.
- Contact number.
- Full address.
- Action row: Call, WhatsApp, Save.
- Similar profiles section.

### 8.3 `03.03 Manufacturer Detail - Work Needed`

Header:

- Back arrow.
- Business name.
- Verified tick if verified.
- Right: share icon, three-dot menu.

Tabs:

- `Work Needed` selected.
- `Profile`.

Content:

- Work-needed post cards.
- Each card:
  - Photo carousel.
  - Work type/name.
  - Category.
  - Product type.
  - Description.

Actions:

- Call.
- WhatsApp.
- Save.

### 8.4 `03.04 Manufacturer Detail - Profile`

Tabs:

- `Work Needed`
- `Profile` selected.

Content:

- Business/shop photo carousel.
- Business name.
- What they manufacture/sell.
- Business category.
- Contact number.
- Full address.
- Action row: Call, WhatsApp, Save.
- Similar profiles.

### 8.5 `03.05 Karigar Detail`

Header:

- Back arrow.
- Name.
- Verified tick if verified.
- Right: share icon, three-dot menu.

Content:

- Worker photo.
- Name.
- Skill.
- Experience.
- Contact number.
- Address.
- Action row:
  - Call.
  - WhatsApp.
  - Save.
- Similar profiles.

No tabs for karigar profile in MVP.

### 8.6 `03.06 Full Screen Gallery`

Purpose:

- Opened when user taps any photo.

Layout:

- Full-screen dark or neutral overlay.
- Large image area.
- Close button.
- Previous/next controls.
- Image count such as `1 / 5`.

## 9. My Profile And Profile Completion

### 9.1 `04.01 My Profile - Incomplete`

Purpose:

- Owner control center before profile is complete.

Layout:

- Header with title: `My Profile`.
- Optional settings icon.
- Dashboard card:
  - Name.
  - Role.
  - Mobile number.
  - Completion percentage.
  - Small progress indicator.
  - Button: `Complete your profile to get business`
- One short tip card.
- Bottom navigation with My Profile selected.

If hide from search is ON:

- Show visible warning badge.

Verification:

- Do not show verification status before submission.

### 9.2 `04.02 Complete Profile - Business Step`

Purpose:

- Step-by-step business profile completion.

Header:

- Back arrow.
- `Complete Profile`

Progress:

- Show progress bar.

Fields:

- Business name.
- Manufacture/sell detail.
- Category.
- Product type.
- Owner name.
- Address.
- Shop photos handled in photo step.

Controls:

- Primary: `Next`
- Secondary: `Save and exit`

### 9.3 `04.03 Complete Profile - Job Worker Step`

Fields:

- Workshop name.
- Owner name.
- Type of work they do.
- Category.
- Product type.
- Address.
- Workplace photos handled in photo step.

Important handoff note:

- Category/product type here is a profile-summary prompt for low-friction onboarding.
- Searchable job-worker offerings are still created as Work Cards.
- If the user has no published Work Card after profile completion, My Profile should show a strong prompt: `Add your first work to appear in search`.
- The backend should not treat the job-worker profile as fully searchable in work results until at least one Work Card is published.

Controls:

- `Next`
- `Save and exit`

### 9.4 `04.04 Complete Profile - Karigar Step`

Step 1 field order:

1. `Name`.
2. Read-only verified `Mobile number`.
3. `Skills` multi-select.
4. Conditional `Other skill` text field.
5. `Skill detail`.
6. `Experience in years`.
7. `About your work`.
8. `Alternate contact number`.

Skills interaction:

- Open a bottom sheet with checkbox rows so the karigar can select multiple skills.
- Include an `Other` option at the end of the list.
- Show `Other skill` only while `Other` is selected.
- Show selected values as removable chips below the selector.
- Require at least one mapped or custom skill before profile completion.
- Save custom skill text immediately and allow backend/admin taxonomy mapping later.

Address and personal photo remain on their dedicated later steps.

Controls:

- `Next`
- `Save and exit`

### 9.4.1 Shared Professional Address Step

Used unchanged for Business, Job Worker, and Karigar profiles.

Field order:

1. Searchable `State / Union Territory`; selecting an option is required.
2. Searchable `City / District`; disabled until a state is selected and limited to that state.
3. `House / shop / building / street` free-text field.
4. `Area / locality` free-text field.
5. Six-digit `PIN code` field.

After six digits, show an inline checking state followed by valid, warning, or invalid feedback. A warning may show tappable postal-area suggestions. Changing state clears city/district and the previous PIN result. Draft saving remains available even before validation is complete.

### 9.5 `04.05 Complete Profile - Photo Upload`

Purpose:

- Photo upload step used by profile completion.

Layout:

- Progress bar.
- Upload button.
- Uploaded photo grid.

Validation:

- If fewer than 3 photos required for the profile type: `Minimum 3 photos required`.

Note:

- Business/shop photos and job-worker workplace photos need minimum 3 for trust/verification.
- Add Work and Add Work Needed also require minimum 3 photos.
- Karigar personal profile photo is a single portrait/photo requirement in the profile-completion flow; do not show the 3-photo validation on the karigar portrait upload unless the screen is explicitly about work photos.

### 9.6 `04.06 Complete Profile - Final Actions`

Purpose:

- Last profile completion step.

Content:

- Review summary card.
- Completion percentage and any remaining required items.
- Primary action: `Complete and publish`.
- Secondary action: `Save and exit`.
- `Previous` returns to the photo step.

Behavior:

- `Complete and publish` saves pending changes, validates every required
  completion item, marks the profile complete, and publishes it.
- If required items are missing, remain on this screen and show them under
  `Still required`.
- `Save and exit` preserves an incomplete draft without publishing it.
- Profile verification is a separate action shown on My Profile only after the
  profile is complete.

### 9.7 `04.07 Job Worker Owner Work List`

Purpose:

- Dedicated owner work-management screen opened from the `Add Work` footer item.

Header:

- `My Work`
- Settings/action icon.

Content:

- List of user's work cards.
- Empty state if none: `Add the work`
- Each work-card row should show:
  - Cover/photo thumbnail or carousel preview.
  - Work name.
  - Category.
  - Product type.
  - Status chip: `Published`, `Hidden`, or `Draft`.
  - Small three-dot action menu.
- Work-card action menu:
  - `Edit work`
  - `Add photos`
  - `Hide from search` / `Show in search`
  - `Delete`
- If the user has no published work card, show prompt:
  - `Add your first work to appear in search`

Sticky button:

- Bottom-right circular `+`.
- Opens Add Work Card.

Bottom navigation:

- Add Work selected.

### 9.8 `04.08 Manufacturer Owner Work Needed`

Purpose:

- Dedicated owner post-management screen opened from the `Add Post` footer item.

Header:

- `Work Needed Posts`.

Content:

- List of user's work-needed posts.
- Empty state: `Find work by posting`
- Each work-needed post row should show:
  - Cover/photo thumbnail or carousel preview.
  - Work name.
  - Product type.
  - Status chip: `Active`, `Paused`, or `Closed`.
  - Small three-dot action menu.
- Work-needed action menu:
  - `Edit post`
  - `Pause`
  - `Close`
  - `Delete`

Sticky button:

- Bottom-right circular `+`.
- Opens Add Work Needed Post.

Bottom navigation:

- Add Post selected.

### 9.9 `04.09 My Profile - Owner Profile Tab`

Purpose:

- Show the owner's own public profile preview plus owner-only controls.

Use as the profile-only My Profile destination for all three roles.

Layout:

- Header: `My Profile`
- Top dashboard strip:
  - Name.
  - Role.
  - Mobile number.
  - Completion percentage.
  - Verification badge only after submission.
- Public preview card:
  - Same core content that other users see on profile detail.
  - Use image carousel if the role has shop/workplace/work photos.
- Owner-only controls:
  - `Edit Profile`
  - `Verify My Profile` when eligible.
  - Disabled edit controls when verification is pending.
- One short improvement tip card.

Bottom navigation:

- My Profile selected.

Annotation:

- This screen must make owner-only controls visually separate from the public preview so users understand what others can see.

## 10. Add Work And Add Work Needed

### 10.1 `05.01 Add Work Card`

Entry:

- Add Work footer -> Work List owner screen -> sticky `+`.

Form style:

- One long form.

Fields in order:

1. Category.
2. Work name.
3. Product type.
4. Photos.
5. Description.

Photo UI:

- Upload button.
- Uploaded photo grid.

Rule:

- Minimum 3 photos.

Submit:

- `Save and Publish`

After submit:

- Return to Work List.
- New card appears in list.

### 10.2 `05.02 Add Work Card - Other Custom`

Purpose:

- Show custom entry when category/work name is missing.

Layout additions:

- Category dropdown with `Other`.
- Text field: `Type category`
- Work name dropdown with `Other`.
- Text field: `Type work name`

Annotation:

- User-entered custom terms can later be mapped by admin to categories.

### 10.3 `05.03 Add Work Card - Photo Validation`

Use same form but show validation near photo grid:

- `Minimum 3 photos required`

### 10.4 `05.04 Add Work Needed Post`

Entry:

- Add Post footer -> Work Needed Posts owner screen -> sticky `+`.

Form style:

- One long form.

Fields in order:

1. Category.
2. Name of the work.
3. Product type.
4. Photos.
5. Description.

Photo rule:

- Minimum 3 photos.

Submit:

- `Save and Publish`

Publish status:

- Always Active in MVP.

### 10.5 `05.05 Add Work Needed - Published`

Purpose:

- Show returned list state with new post.

Layout:

- Work Needed Posts list.
- New post card appears at top.
- Status chip: `Active`.

## 11. Verification Screens And States

### 11.1 `06.01 Verification Not Eligible`

Where:

- My Profile or final profile completion step.

State:

- Verification button disabled.
- Message: `Complete profile first`

### 11.2 `06.02 Verification Submit Ready`

Where:

- Final profile completion step or My Profile action area.

CTA:

- `Verify My Profile`

Submission includes:

- Manufacturer: profile details, shop photos, optional ID proof, optional GST proof.
- Job Worker: profile details, shop photos, optional ID proof, optional GST proof.
- Karigar: profile details, skill details, optional ID proof.

Do not create a long verification intro screen.

### 11.3 `06.03 Verification Pending - Locked`

Where:

- My Profile.

Layout:

- Completion/verification badge near completion percentage:
  - `Pending review`
- Edit buttons visible but disabled.
- Annotation: profile editing locked while pending.

### 11.4 `06.04 Verification Approved`

Where:

- My Profile and public profile.

Owner view:

- Badge near completion: `Approved`

Public view:

- Blue tick only.
- No detailed verification breakdown.

### 11.5 `06.05 Verification Changes Requested Notification`

Where:

- Notifications list.

Notification row:

- Title: `Changes requested`
- Message: short admin message placeholder.
- Date/time.

Tap behavior:

- Opens `06.06 Verification Changes Requested - Resubmit`.

### 11.6 `06.06 Verification Changes Requested - Resubmit`

Purpose:

- Let the user understand exactly what admin asked them to fix and resubmit verification without creating a long verification intro flow.

Where:

- Opened from the `Changes requested` notification.
- Also reachable from My Profile when `verification_status = changes_requested`.

Layout:

- Header: `Verification`
- Status badge near top: `Changes requested`
- Admin message card:
  - Short message from admin.
  - Example placeholder: `Please add clearer shop photos.`
- Checklist rows:
  - Profile details.
  - Shop/workplace photos.
  - Optional ID proof.
  - Optional GST proof for business/job-worker.
- Only rows needing changes should show active edit/upload buttons.
- Rows that are already accepted should show a simple done state.

Actions:

- Primary: `Update and Resubmit`
- Secondary: `Save and exit`

Rules:

- Do not show public verification breakdown.
- Do not allow users to edit unrelated locked fields during pending review unless admin requested that field.
- After resubmission, return to `06.03 Verification Pending - Locked`.

## 12. Saved, Share, Report, Notifications, Settings

### 12.1 `07.01 Saved`

Layout:

- Header title: `Saved`
- Tabs:
  - Business.
  - Job Worker.
  - Karigar.
- Saved item cards.

Card style:

- Same as search result card.
- Include remove button.

Bottom navigation:

- Saved selected.

### 12.2 `07.02 Saved - Empty`

Text:

- `No saved profiles`

### 12.3 `07.03 Share Sheet`

Entry:

- Profile detail share icon only.

Options:

- Copy link.
- WhatsApp.
- SMS.
- X.
- Email.
- LinkedIn.
- Other native share apps.

### 12.4 `07.04 Report Reason Sheet`

Entry:

- Profile detail three-dot menu -> Report.

Reasons:

- Wrong contact.
- Wrong category.
- Inappropriate photo.
- Wrong details.

No optional text box.

Submit:

- `Submit report`

### 12.5 `07.05 Report Submitted Toast`

Behavior:

- Return to previous profile detail screen.
- Toast confirmation at bottom:
  - `Report submitted`

### 12.6 `07.06 Notifications`

Entry:

- Home header bell.

Layout:

- Header title: `Notifications`
- Simple list.

Notification row:

- Title.
- Short message.
- Date/time.

Example rows:

- `Verification submitted`
- `Profile approved`
- `Changes requested`

### 12.7 `07.07 Notifications - Empty`

Text:

- `No notifications`

### 12.8 `07.08 Settings`

Entry:

- My Profile settings/action icon.

Items:

- Notification settings.
- Hide from search.
- Contact support.
- Logout.

Logout:

- No confirmation.

Contact support:

- WhatsApp/call support button.

### 12.9 `07.09 Settings - Hide From Search On`

Layout:

- Hide from search toggle ON.
- Warning text:
  - `Your profile will not appear in search.`

My Profile related state:

- Show visible warning badge when hidden.

## 13. State Variant Screens

### 13.1 `08.01 Loading Skeleton`

Use:

- Search result loading.

Layout:

- Header/search row.
- 2-3 skeleton result cards.

### 13.2 `08.02 Network Error`

Text:

- `Can't access internet`

Action:

- `Retry`

### 13.3 `08.03 Permission Required`

Use:

- Photo/gallery permission denied.

Text:

- `Permission required`

Action:

- `Open settings`

### 13.4 `08.04 Upload Failed`

Text:

- `Unable to upload, please retry`

Action:

- `Retry`

## 14. Prototype Journeys

Connect only these three main journeys.

### 14.1 Journey 1: Manufacturer Finds Flat Hemming Job Worker

Flow:

1. Home.
2. Tap `Find Job worker, value adder`.
3. Fixed-target Job Worker Search opens with Work selected.
4. User searches `flat hemming`.
5. Results show work-first job-worker cards.
6. User taps a work card.
7. Job Worker Detail opens on Work List.
8. User switches to Profile tab.
9. User taps Call or WhatsApp.

Arrow labels:

- `Find job worker`
- `Search flat hemming`
- `Open work card`
- `View profile`
- `Contact`

### 14.2 Journey 2: Job Worker Adds Work Card

Flow:

1. Tap `Add Work` in the job-worker footer.
2. Work List owner screen.
3. Tap sticky `+`.
4. Add Work Card.
5. Select category.
6. Select work name.
7. Select product type.
8. Upload minimum 3 photos.
9. Tap `Save and Publish`.
10. Return to Work List with new card.

Arrow labels:

- `Add work`
- `Fill work details`
- `Upload photos`
- `Publish`

### 14.3 Journey 3: Manufacturer Posts Work Needed

Flow:

1. Tap `Add Post` in the manufacturer footer.
2. Work Needed Posts owner screen.
3. Tap sticky `+`.
4. Add Work Needed Post.
5. Select category.
6. Add work name and product type.
7. Upload minimum 3 photos.
8. Tap `Save and Publish`.
9. Return to Work Needed Posts with new Active post.

Arrow labels:

- `Add work needed`
- `Fill post`
- `Upload photos`
- `Publish active`

## 15. Annotations To Add In Figma

Add annotations only near complex screens.

Search annotations:

- `Search target is fixed by the Home card; return Home to change persona.`
- `Business has Work Needed / Profiles, Job Worker has Work / Profiles, and Karigar has no secondary tabs.`
- `Result cards never show contact or full address.`
- `Filters are modular and can change after user feedback.`

Profile detail annotations:

- `MVP shows contact/address only after opening profile.`
- `Public users see only blue tick, not verification breakdown.`
- `Actions are inside content, not sticky.`

My Profile annotations:

- `Owner view has controls that visitors do not see.`
- `Bottom nav is visible here.`
- `Hide from search is managed from Settings.`

Verification annotations:

- `Pending review locks edit buttons.`
- `Changes requested appears in Notifications.`
- `Changes requested opens a targeted fix-and-resubmit screen.`

Add Work annotations:

- `Add Work uses one long form, not step-by-step.`
- `Minimum 3 photos required before publishing.`
- `Other option opens custom text field.`

## 16. Explicit Do-Not-Include Rules

Do not include:

- Admin screens.
- Payment/subscription screens.
- Ratings/reviews.
- Voice search.
- Map/GPS screens.
- iOS screens.
- Full multilingual UI.
- Customer support chat.
- Order management.
- In-app job/payment negotiation.
- Contact reveal paywall.

Do not show contact/address on:

- Search result cards.
- Saved cards if they use result-card style.

Do not show public verification detail beyond:

- Blue tick.

## 17. Conflict Resolutions

Use these latest decisions if older files disagree:

- Role selection happens after OTP, not before.
- Role confirmation is full-screen before Home.
- Add Work Card requires minimum 3 photos.
- Add Work Needed Post requires minimum 3 photos.
- Report has no optional text box.
- Saved screen uses three top tabs: Business, Job Worker, Karigar.
- Bottom navigation is role-specific: manufacturer has Add Post, job worker has Add Work, and karigar has three items; Search is never a footer item.
- Add Post and Add Work open dedicated owner list screens; My Profile is profile-only.
- No admin screens in this wireframe.
- Figma build should be created only after this spec is reviewed.

## 18. Figma Build Readiness Checklist

Before calling Figma:

- Confirm the Figma account has edit access, not only View access.
- Confirm whether to create a new file or update an existing editable file.
- Confirm file title.
- Confirm whether the one-attempt limit means generating all screens in one file in one pass.
- Confirm final app name remains `Connect` for wireframe.

Ready-to-build file title:

`Textile Marketplace MVP - Mid Fidelity Wireframes V3`

Recommended Figma page name:

`Wireframe Spec V3`

## 19. Build Priority If Tool Limits Are Tight

If Figma execution/token/tool limits are tight, build in this order:

1. Entry flow.
2. Home.
3. Search and result cards.
4. Job Worker and Manufacturer profile detail.
5. My Profile owner views.
6. Add Work and Add Work Needed forms.
7. Verification states.
8. Saved/notifications/settings.
9. Extra state variants.
10. Critical journey annotation strip.

Never skip:

- Home.
- Search.
- Job-worker result card.
- Job-worker profile detail.
- My Profile.
- Add Work Card.
- Manufacturer Add Work Needed.
- Verification pending/approved states.
- Verification changes-requested/resubmit state.
