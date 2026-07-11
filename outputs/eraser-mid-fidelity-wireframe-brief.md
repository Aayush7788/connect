# Eraser Mid-Fidelity Wireframe Brief

Create a mid-fidelity Android mobile wireframe board for a Surat-first textile marketplace MVP.

The app connects:
- Manufacturers / businesses who need textile value-addition work.
- Job workers / value adders who perform work such as flat hemming, embroidery, printing, lace work, dyeing, overlock stitching.
- Skilled workers / karigars who offer individual textile skills.

The board must feel like a real product team artifact, not an architecture diagram.

## File

Create a new shared team Eraser file named:

`eraser_wireframe_mid_fidelity_v2`

## Diagram Set

Create multiple diagrams in the same file if possible:

1. `01 Entry Home Nav`
2. `02 Search Results Filters`
3. `03 Profile Detail Screens`
4. `04 Owner Profile Create Verify`
5. `05 Saved Share Report Notifications`
6. `06 Annotated Critical User Journeys`

## Visual Standard

- Draw phone-sized frames with Android proportions.
- Each phone frame must include realistic UI structure: top bar, content area, cards, buttons, chips, image placeholders, form fields, and bottom navigation where applicable.
- Use annotations/callouts beside screens.
- Use arrows between screens.
- UI text is English for MVP, but annotations should mention future Gujarati/Hindi support and low-digital-literacy considerations.
- Do not show contact/address on result cards. In MVP, contact/address is visible only after profile detail opens.

## Screens To Include

### Entry + Home

Frames:
- Splash: logo placeholder, short loading state.
- Create account: name and mobile number only.
- OTP verify: OTP fields, resend OTP, support later.
- Select role: three large options: Manufacturer / Business, Job Worker / Value Adder, Skilled Worker / Karigar.
- Home: three large discovery buttons: Find Manufacturer / Business, Find Job Worker / Value Adder, Find Skilled Worker / Karigar. Show completion banner if profile incomplete. Bottom nav: Home, Search, Saved, My Profile. Bell icon top right.

Rules:
- New users must create account before searching.
- Role selection happens after OTP verification, not before OTP.
- Returning logged-in users land on Home.
- Role is stored on account and cannot change once profile is complete.

### Search + Results

Frames:
- Global Search screen with tabs: Businesses, Job Workers, Karigars.
- Persona-specific search opened from Home.
- Filter drawer/sheet with Category/Work Type, Product Type, Verified.
- Empty search: "Request this work" and "Invite someone".
- Loading skeleton cards.
- Connection issue retry state.

Result cards:
- Manufacturer card: product/work photos, business name, category chips, locality, verified tick. No contact/address.
- Job worker card: work-entry first: work photo, work name, category/product chips, workshop name, verified tick. No contact/address.
- Karigar card: worker photo, name, skill, experience, locality, verified tick. No contact/address.

Sorting:
- Verified first, nearby, most complete profile, then promoted later.

### Profile Detail

Frames:
- Manufacturer detail default tab: Work Needed Posts. Second tab: View Profile.
- Manufacturer View Profile: business name + blue tick, workplace photos, owner name, what they manufacture, contact, address.
- Job worker detail default tab: Work List. Second tab: View Profile.
- Job worker View Profile: job worker business name + blue tick, workplace photos, owner name, work types, contact, address.
- Karigar detail: name, photo, mastery skill, experience, address, contact.
- Full-screen gallery state.

Actions:
- Call, WhatsApp, Save, Share, Report.
- Similar profiles below detail.
- Blue tick only when full admin-approved verification is complete.

### My Profile + Creation + Verification

Frames:
- My Profile: public preview plus owner-only controls: name, role, completion percent, edit button, hide from search toggle, profile improvement tips.
- Manufacturer actions: Edit Profile, Work Needed, View My Posts, Submit Verification.
- Job worker actions: Edit Profile, View and Add Work, Add Work Card, Edit Work Card, Submit Verification.
- Karigar actions: Edit Profile, Submit Verification.
- Edit Profile long form. Mobile number and owner name locked.
- Add Work Card: category, custom category if missing, work name, custom work name if missing, product type mandatory, photos minimum 1, description, Save & Publish.
- Add Work Needed Post: work type, category, product type, photos, description, status active/paused/closed, Save & Publish.
- Verification CTA active only after required fields complete. States: incomplete, pending review, approved blue tick, rejected/changes requested.

Rules:
- Save incomplete profile and complete later.
- Changing verified fields removes blue tick and requires re-verification.
- Work card publishes immediately in MVP.
- Work-needed post publishes immediately in MVP.

### Saved / Share / Report / Notifications / Settings

Frames:
- Saved grouped tabs: Businesses, Job Workers, Karigars, Work Needed.
- Share sheet: WhatsApp, X, LinkedIn, Email, Copy Link, Invite App Install.
- Report form: fake profile, wrong contact, wrong category, inappropriate photo, spam, optional details, submit.
- Report status list.
- Notifications: verification submitted, approved, rejected, changes requested, complete profile reminder.
- Settings: notification settings, logout, contact support later, future language/privacy/account termination placeholders.

### Critical User Journeys

Show three numbered flows with arrows:

1. Manufacturer finds flat hemming job worker:
   Home -> Find Job Worker -> Search "flat hemming" -> Filter verified/product type -> Results -> Job worker work card -> Work List -> View Profile -> Call/WhatsApp/Save.

2. Job worker adds work card:
   My Profile -> View and Add Work -> Add Work -> Select category/work name/product type -> Upload photos -> Save & Publish -> Work card appears in profile/search.

3. Manufacturer posts work needed:
   My Profile -> Work Needed -> Add Work Needed -> Fill work type/category/product/photos/description -> Publish active -> Job workers discover post -> Open manufacturer detail -> Contact.

## Output

Return:
- File title
- File URL
- Diagram URLs
- Short section list
