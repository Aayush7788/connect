# Textile Marketplace Mid-Fidelity Mobile Wireframe Spec

Date: 2026-07-05
Status: Ready for Eraser creation after OAuth re-authorization
Source: `outputs/textile-marketplace-app-flow-spec.md`

## Wireframe Standard

This wireframe should be treated like a product team artifact, not a rough diagram.

Use Android mobile frames with:

- realistic headers, bottom navigation, tabs, cards, forms, buttons, banners, and empty states
- grayscale UI with only minimal accent for warnings, verified tick, and primary actions
- large touch targets
- clear owner vs visitor states
- annotated user flows beside screens
- enough field/button detail for Flutter implementation

## Board Sections

### 1. Entry Flow

Screens:

- Splash
- Create Account
- OTP Verification
- Select Role

Key decisions:

- No browsing before account creation.
- New user enters mobile number and name first.
- User verifies OTP next.
- User selects role only after OTP succeeds.
- Selected role is saved to the user's account/profile before Home opens.
- Returning logged-in user goes directly to Home.
- Role cannot be changed after profile completion.

### 2. Home

Main screen:

- Header with app name and notification bell.
- Prompt: `What do you want to find?`
- Three discovery cards:
  - Find Manufacturer / Business
  - Find Job Worker / Value Adder
  - Find Skilled Worker / Karigar
- Complete Profile banner if incomplete.
- Tip card: `Add 3 photos to improve ranking`.
- Bottom nav: Home, Search, Saved, My Profile.

### 3. Search

Global Search screen:

- Search input.
- Filter button.
- Persona tabs:
  - Businesses
  - Job Workers
  - Karigars
- Only one persona tab active at a time.
- Default results before search: verified, local, most complete.

Filter bottom sheet:

- Category / work type.
- Product type.
- Verified toggle.
- Apply filters.
- Clear.

States:

- Loading skeleton cards.
- No results: `Request this work`, `Invite someone to the app`.
- Connection issue: retry.

### 4. Result Cards

Manufacturer card:

- Product/work image.
- Business name.
- Verified tick if verified.
- Category chips.
- Business/work type.
- Locality.
- No phone/address on card.

Job worker card:

- Work-entry first.
- Work photo.
- Work name.
- Workshop/job-worker name below.
- Category chip.
- Product type chip.
- Verified tick if verified.
- No phone/address on card.

Karigar card:

- Worker photo.
- Name.
- Skill/work.
- Experience.
- Locality.
- Verified tick if verified.
- No phone/address on card.

### 5. Profile Details

Manufacturer detail:

- Tabs: Work Needed Posts, View Profile.
- Default: Work Needed Posts.
- Work-needed post cards with photo, work type, category, product type, description, active/paused/closed status.
- View Profile tab: business name, verified tick, workplace gallery, owner name, what they manufacture, contact, address, Call, WhatsApp.

Job worker detail:

- Tabs: Work List, View Profile.
- Default: Work List.
- Work cards grouped by work type.
- View Profile tab: workshop name, verified tick, shop gallery, owner name, work types, contact, address, Call, WhatsApp.

Karigar detail:

- Name.
- Photo.
- Skill/mastery.
- Experience.
- Address.
- Contact.
- Call, WhatsApp, Save, Share, Report.

Rules:

- Contact/address visible on profile in MVP.
- Later this becomes Show Contact.
- Public users see only blue tick, not verification details.

### 6. My Profile

Common owner view:

- Name.
- Role.
- Completion percentage.
- Edit button.
- Owner-only verification status.
- Public profile preview.
- Hide from search toggle.
- Completion tips.

Manufacturer actions:

- Edit Profile.
- Work Needed.
- View My Posts.
- Add Photos to Post.
- Submit Verification.

Job worker actions:

- Edit Profile.
- View and Add Work.
- Add Work Card.
- Edit Work Card.
- Submit Verification.

Karigar actions:

- Edit Profile.
- Submit Verification.

### 7. Edit Profile

Use a long editable form, not onboarding steps.

Locked:

- Mobile number.
- Owner name.
- Role after profile completion.

Warning:

- Editing verified fields removes blue tick and requires reverification.

Role groups:

- Manufacturer: business name, manufacture details, category, address, photos.
- Job worker: workshop name, work summary, category, address/photos.
- Karigar: skill, experience, address, contact.

### 8. Add Work Card

Entry:

- My Profile -> View and Add Work -> Add Work.

Fields:

- Category.
- Category not listed? type category.
- Work name.
- Work not listed? type work name.
- Product type, mandatory.
- Photo uploader, minimum 1.
- Description.
- Save and Publish.

Rules:

- One category per work card.
- Publishes immediately.
- No admin approval in MVP.
- Cannot save with 0 photos.

### 9. Add Work Needed

Entry:

- My Profile -> Work Needed -> Add Work Needed.

Fields:

- Work type.
- Category.
- Product type.
- Photos.
- Description.
- Publish.

Management:

- Edit.
- Delete.
- Pause.
- Close.

Rules:

- Publishes immediately.
- No admin approval in MVP.
- Photos show what kind of work is needed.

### 10. Verification

States:

- Eligible to verify.
- Pending review.
- Approved.
- Rejected / changes requested.

Rules:

- Starts from My Profile.
- No long verification intro screen.
- Verification is free.
- Blue tick means admin checked profile/photos/documents manually.
- Rejection reasons are owner-only.
- Pending profile cannot be edited.

### 11. Saved, Share, Report, Notifications, Settings

Saved:

- Groups: Businesses, Job Workers / Work Cards, Karigars, Work Needed Posts.
- Empty state: `No saved items yet`.

Share:

- Profile.
- Work card.
- Work-needed post.
- App invite.
- Targets: WhatsApp, X, LinkedIn, Email, system share.

Report:

- Fake profile.
- Wrong contact.
- Wrong category.
- Inappropriate photo.
- Spam.
- Optional details.
- Report status.

Notifications:

- Verification submitted.
- Approved.
- Rejected.
- Changes requested.
- Profile completion reminders.

Settings:

- Notification settings.
- Logout.
- Contact support later.
- Future: terms/privacy, language, account termination, help, app version.

### 12. Critical Annotated User Flows

Manufacturer finds flat hemming job worker:

`Home -> Find Job Worker -> Search flat hemming -> Work-entry card -> Job Worker Work List -> View Profile -> Call / WhatsApp`

Job worker adds work card:

`My Profile -> View and Add Work -> Add Work -> Category -> Work Name -> Product Type -> Upload Photo -> Description -> Save / Publish`

Manufacturer posts work needed:

`My Profile -> Work Needed -> Add Work Needed -> Work Type -> Category -> Product Type -> Photos -> Description -> Publish`

## Eraser Creation Note

The previous Eraser write failed because Eraser returned:

`OAuth authorization required`

Once OAuth is completed, create a new Eraser diagram named:

`mid_fidelity_mobile_wireframes`

Recommended placement:

- Existing file: `eraser_wireframe`
- Or new shared team file if preferred
