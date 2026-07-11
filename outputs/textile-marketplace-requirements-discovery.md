# Textile Marketplace Requirements Discovery

Date: 2026-07-01
Status: Discovery in progress

This file stores confirmed answers from the requirements loop. The final high-level system design should use this file as the source of truth before making architecture decisions.

## Round 1: Product Boundary

### Confirmed Answers

1. **Launch geography**
   - Start with Surat as the priority market.
   - Expand to all India later.
   - The product should not be architecturally dependent on Surat only, because the marketplace model can work beyond one city.

2. **Core personas**
   - Persona A: textile manufacturers, wholesalers, and traders who need value-adding work done.
   - Persona B: job workers, value adders, workshops, and small teams that perform specific textile processes.
   - Persona C: skilled individual workers currently described as labourers, but the in-app label should use a better term.

3. **Primary product model**
   - The app is mainly a directory/search marketplace.
   - It should show what Persona B does, including work categories, work photos, shop/workplace photos, and updates when Persona B starts offering new types of work.

4. **Order management**
   - No in-app order management for the first design.
   - The app's job is to connect different personas based on their needs.

5. **Payments**
   - No in-app job/order payments at the start.
   - Start with contact reveal and lead generation.

6. **Monetization**
   - Businesses, job workers/value adders, and skilled workers who want to connect with others may pay.
   - Payment is tied to seeing contact details and addresses after the initial/demo phase.

7. **Initial onboarding priority**
   - Highest priority: manufacturers/traders and job workers/value adders.
   - Skilled workers are also part of the marketplace, but not the first supply focus.

8. **Skilled worker discoverability**
   - Anyone can search for skilled workers.
   - The app should not call them "labourers"; a better product label is needed.

9. **Contact reveal**
   - In the starting/demo phase, contact details can be directly visible.
   - Later, users must purchase a plan to see more contacts, addresses, and phone numbers.

10. **Languages and input**
    - Required languages: English, Gujarati, and Hindi.
    - Search should support Hinglish/Gujarati voice search.

11. **Platform scope**
    - Full mobile app only for users.
    - Admin must be able to see all collected platform information, similar to what a developer/database admin can inspect.

12. **First success metrics**
    - Verified profiles for job workers/value adders, business owners, and skilled workers.
    - Contact reveals.
    - Job/service searches.
    - Highly accurate search system.

### Open Items From Round 1

- Final in-app name for Persona C.
- Whether plan purchase means subscription, prepaid contact credits, lead packs, or hybrid.
- Whether admins need a web dashboard, mobile-only admin mode, or backend database/reporting access.
- Exact definition of "verified profile" for each persona.

## Round 2: Trust, Verification, Fraud

### Confirmed Answers

1. **Persona A registration fields: textile businesses**
   - Name.
   - Mobile number.
   - Shop/business address.
   - Shop photos.
   - Aadhaar verification, if legally and operationally feasible.
   - GST verification, if feasible.
   - What they manufacture.
   - What they sell.
   - What kind of value-adding work they need for their business.
   - Years in business.

2. **Persona B registration fields: job workers/value adders**
   - Name.
   - Mobile number.
   - Work address / place where the work is performed.
   - Aadhaar verification or another identity verification method, if feasible.
   - GST verification, if feasible.
   - Type of work performed.
   - Proof-of-work photos.
   - Workplace photos.
   - Years doing the work.
   - Preferred / expert work category.

3. **Persona C registration fields: skilled workers / karigars**
   - Name.
   - Mobile number.
   - Skills / work they do.
   - Experience.
   - Aadhaar verification or other identity proof, if feasible.
   - Address.

4. **Identity verification direction**
   - The final verification model needs deeper research.
   - If KYC is feasible, identity verification should be mandatory for all verified users.
   - The app should not depend only on Aadhaar; another identity proof should work where appropriate.

5. **Aadhaar data handling**
   - Research required before deciding.
   - Need to determine whether the app can legally collect Aadhaar details, whether it should only use Aadhaar-based verification through an approved provider, and what data should be stored.

6. **Face capture and liveness**
   - Face capture with blink/liveness should be required for users who want a verified badge or contact-reveal access.
   - It should not necessarily be required for every low-friction registration.

7. **GST verification**
   - Research required before deciding final implementation.
   - If GST verification is feasible for business owners, the app should support it.

8. **Address and workplace proof**
   - Minimum: at least 3 shop/workplace photos.
   - Capture live GPS location during registration form submission.
   - Allow manually added address.
   - Consider GST address for business users, but this needs deeper design.

9. **Verified vs unverified marketplace**
   - The app should have two profile groups:
     - Unverified business/job-worker profiles.
     - Verified business/job-worker profiles.
   - Contacting verified profiles should require a subscription/plan after launch/demo.
   - Verified profiles reduce scam risk and create monetization value.

10. **Verification badge**
    - A blue tick should mean the profile is fully verified.
    - Full verification means mobile, identity/Aadhaar where available, GST where applicable, shop/workplace, face/liveness, and admin approval are all complete.

11. **Multiple roles**
    - No multi-role account in the starting product.
    - At registration, the user must choose one role: manufacturer/business, job worker/small team, or skilled individual.
    - Profile-completion flow depends on the selected role.

12. **Launch friction**
    - Launch should be low-friction first.
    - Users can stay unverified, but verified profiles should receive stronger trust signals and contact-monetization value.

13. **Reporting and feedback**
    - Users can give profile feedback.
    - Users can report fake profiles, wrong claims, bad behavior, or spam to the app team.

14. **Contact reveal abuse**
    - Multiple contact reveals should be available only to users who purchased a plan/subscription.
    - The system should still track contact reveal volume for abuse and plan enforcement.

15. **Phone reveal model**
    - Direct profile/contact reveal is acceptable.
    - In-app masked calling is not required for the initial product.

16. **Failed verification**
    - Users can retry verification.
    - Users may remain unverified instead of being blocked by default.

17. **Persona C label**
    - Preferred label direction: Skilled Workers / Karigars.

### Open Items From Round 2

- Research legal and compliance limits around Aadhaar verification, storage, masking, consent, and third-party KYC providers.
- Research GST verification options and whether GST verification can be done reliably through an API/provider.
- Decide whether all verified users require admin approval or only high-risk profiles.
- Decide whether unverified profiles can reveal contact details or only basic public information.
- Define exact blue-tick rules for users without GST, especially skilled workers/karigars.
- Decide whether Persona C should be called "Skilled Worker", "Karigar", or a combined label such as "Skilled Karigar".

## Round 3: Search, Taxonomy, Profiles

### Confirmed Answers

1. **Primary search dimensions**
   - Service name.
   - Product type.
   - Verified-only filter.
   - Photos/work-sample filter.
   - Machine-type work.
   - Location, experience, and verified status should be available as filters.

2. **Example searches**
   - Flat hemming worker.
   - Digital print on dupatta job work.
   - Zari hand work karigar.
   - Jarkhand work.
   - Search bar should support filters for location, experience, and verified status.

3. **Search language tolerance**
   - Search must understand spelling mistakes.
   - Search must understand local names.
   - Search must understand mixed languages, including Hindi, Gujarati, Hinglish, and local textile terms.

4. **Product-to-work discovery**
   - Users should be able to search/filter by product/item such as dupatta, saree, kurti, or fabric.
   - The app should suggest possible work types for that product.
   - This should appear as part of the search/filter experience.

5. **Service taxonomy entry**
   - Users should be given predefined service/work categories to select from.
   - If the correct option is missing, users should be able to freely write what they do.
   - The app should map free-text entries into categories where possible.

6. **Persona A public demand**
   - Manufacturer profiles should show what they manufacture.
   - Manufacturers should also be able to post what type of work they need from time to time.
   - The app should show these work-needed posts to relevant job workers.
   - If a job worker is interested, they can contact the manufacturer.
   - This is a lightweight lead/demand post, not full order management.

7. **Availability and capacity**
   - Do not show current availability or capacity in the initial product.
   - Examples deferred: available now, busy, pieces/day, urgent work accepted.
   - Build this later only if user feedback proves it is needed.

8. **Skilled worker pricing**
   - Do not show daily wage, monthly salary expectation, or pricing initially.
   - The app's role is to connect users; negotiation and business terms happen outside the app.

9. **Location display**
   - Show area/locality text only.
   - Do not require map directions in the initial product.

10. **Search ranking priorities**
    - Verified profiles first.
    - Nearest profiles.
    - Best profile/profile-completeness quality.
    - Paid/promoted profiles.

11. **Saved profiles and searches**
    - Users can save/favorite profiles.
    - Users can save or revisit useful searches.
    - To see locked contact information, users must have an active plan/subscription.

12. **Photo requirement and search results**
    - Work photos should be central to search-result quality.
    - Search results should show the profile, kind of work the profile does, work photos, and work category.
    - If users like the work from the photo, they can open the profile for more information.

13. **Ratings and admin verification**
    - Add user ratings.
    - Also keep admin verification.

14. **Demand posts vs order management**
    - No full "I need this work" order/job management flow.
    - Lightweight manufacturer work-needed posts are allowed as discovery/lead posts.

15. **Service category growth**
    - Service categories will increase in the future.
    - The full starting taxonomy is not known yet.
    - Architecture should support adding new categories, aliases, and mappings over time.

### Open Items From Round 3

- Research and build a deeper textile service taxonomy for Surat and later India.
- Decide exact search ranking formula among verified, nearby, complete, active, rated, and paid/promoted profiles.
- Decide whether paid/promoted profiles can outrank verified organic profiles or only appear in sponsored slots.
- Define what "best profile" means: completeness, rating, photo quality, recency, verification, contact response, or a weighted score.
- Decide how ratings are allowed when the app does not manage orders: contact-based rating, verified interaction rating, or open rating with anti-abuse checks.
- Decide if manufacturer work-needed posts expire automatically after a number of days.

## Round 4: Monetization, Plans, Contact Reveal

### Confirmed Answers

1. **Free search**
   - Search is free for everyone.
   - Anyone can use the search bar and search for any work.

2. **Free contact reveals for new users**
   - After monetization starts, new users should get 5 to 8 free contact reveals.
   - If the user wants more profile/contact reveals after that, they must purchase a subscription plan.

3. **Launch/demo pricing**
   - During demo/launch, the whole app should be free.
   - Unlimited contact reveals should be available during the launch phase.
   - Goal: encourage everyone to add their details and help seed marketplace supply.

4. **Initially free app features**
   - In the starting process, all app features should be free.
   - The app should not charge anything at launch.

5. **Future locked features**
   - Exact address.
   - Contact number.
   - Verified-only list.
   - Unlimited profile/contact views.
   - These should be locked behind subscription after monetization starts.

6. **Plan model**
   - Monthly subscription.
   - Yearly subscription.
   - No pay-per-contact or contact-credit plan confirmed for now.

7. **Plan differences by persona**
   - Same plan for everyone.
   - No separate manufacturer/job-worker/karigar plan at the start.

8. **Verified-profile benefits**
   - Verified profiles should receive 3 free contact reveals.

9. **Promoted profiles**
   - Users should eventually be able to pay to promote/top-rank their own profile.
   - This is a later feature, not initial launch scope.

10. **Verification pricing**
    - Verification should be free.
    - Contact reveal is the paid feature later.

11. **Contact reveal after purchase**
    - Contact details should be visible immediately after successful plan purchase.
    - No reason/request flow is needed before contact reveal.

12. **Saved profiles**
    - Saving/favoriting profiles should be free.
    - Contact information inside saved profiles remains locked unless the user has a paid plan or available free reveals.

13. **Profile-view analytics**
    - Users should be able to see who viewed or revealed their profile/contact.
    - This should be included in the paid plan.

14. **Admin free plans/coupons**
    - Admin should be able to make the app free for early Surat users.
    - Early-user free access is part of the go-to-market strategy.

15. **Payment method**
    - Payment methods are not decided yet.
    - Decide later when subscription plans are added.

16. **Invoices/GST billing**
    - Invoice/GST billing is not required for paid plans from the beginning.

### Open Items From Round 4

- Decide exact free reveal count after launch: 5, 6, 7, or 8.
- Decide when the app moves from free launch mode to paid subscription mode.
- Define whether "unlimited profile view" means unlimited profile opens, unlimited contact reveals, or both.
- Decide whether verified users receive 3 free reveals one-time, monthly, or after each verification renewal.
- Decide if free launch contact reveals should still be metered invisibly for analytics and future pricing design.
- Decide future payment gateway when monetization is introduced.

## Round 5: Admin, Operations, Moderation

### Confirmed Answers

1. **Admin panel requirement**
   - Admin panel is required.
   - During early app development, it is acceptable if the admin panel is not complete immediately.
   - The final product needs a proper admin panel.

2. **Admin panel platform**
   - Prefer web dashboard if it is easier.

3. **Admin capabilities**
   - Admin should have full control over the platform.
   - Expected controls include profile approval, rejection, verification, reports, users, categories, subscriptions, notifications, analytics, and moderation.
   - The target admin capability level should be similar to large marketplace/social platforms, while implementation can be phased.

4. **Manual verification review**
   - At the start, admin should manually review shop photos, work photos, and verification evidence before approving a verification badge.

5. **Admin profile edits**
   - Admin should not directly change user-submitted profile information by default.
   - Admin can approve, reject, or request changes from the user.

6. **Profile update re-approval**
   - Only sensitive changes should require re-approval.
   - Sensitive changes likely include mobile number, address, GST, KYC/identity, and service categories.
   - More research/detail is needed.

7. **User reports**
   - Reports should create an admin review task.
   - Reports should not automatically hide a profile in the initial design.

8. **Admin-created profiles / bulk seed data**
   - Admin should be able to add profiles for some users at the start for demo and initial launch.
   - Admin should be able to support initial seed data entry.

9. **Existing offline data**
   - No offline data is available right now.
   - The founder expects to find/manage initial data for initial development.

10. **Field agents**
    - Field agents are not needed at the start.
    - Field agents may be added after the app is successful.

11. **Field agent login/tracking**
    - Not required now because field agents are out of initial scope.

12. **Initial analytics**
    - Total profiles.
    - Verified profiles.
    - Search terms.
    - Contact reveals.
    - Top categories.

13. **Admin notifications**
    - Admin should be able to send notifications to users.

14. **Customer support**
    - Customer support chat/call should be available inside the app.

15. **Account/data deletion**
    - User-requested account/data deletion is not required in the founder's initial product expectation.

### Open Items From Round 5

- Decide minimum admin panel feature set for MVP vs later full-control admin.
- Define sensitive profile updates that require re-approval.
- Decide if admin-created profiles need owner claim/verification later.
- Decide whether bulk upload should support CSV/Excel import in the first admin version.
- Decide support workflow depth: simple ticket/chat log vs real-time support chat vs call notes only.
- Account/data deletion may still be required for legal/privacy compliance even if not a desired product feature; research required.

## Round 6: Mobile App UX, Onboarding, Low-Digital-Literacy

### Confirmed Answers

1. **Registration start**
   - Mobile OTP.
   - Name.
   - Role selection.

2. **Onboarding length**
   - Onboarding should be very short.
   - Detailed profile completion happens later.

3. **Verification timing**
   - Users can skip verification.
   - Users can complete verification later.

4. **Persona B profile setup**
   - Form-based.
   - Guided step-by-step process.
   - Examples/photos can be used to guide users.

5. **Voice for profile creation**
   - No voice recording for "what work do you do" in the initial product.
   - Users type their work details and complete profiles themselves.

6. **Voice search**
   - Voice input/search is not required from day one.
   - Voice search should come later.

7. **Persona search flow**
   - App should show buttons for what the user wants to find.
   - Example: manufacturer wants a job worker, selects job-worker search, then searches for the needed job work.
   - Example: job worker wants a skilled worker/karigar, selects skilled-worker search, then searches for the needed skill.
   - This persona-targeted search flow applies across the app.

8. **Home screen**
   - Search bar.
   - Buttons for which persona/type the user wants to find.
   - Profile setup prompt.
   - Option to add what type of work is needed or wanted, based on the user's selected persona.

9. **Profile completeness**
   - Show profile completeness percentage.
   - If profile is 100% complete, the user can become verified.

10. **Visual UI**
    - Use icons heavily.
    - UI should support users who may not read English well.

11. **Language support**
    - Full translated UI is required.
    - Required languages: English, Hindi, Gujarati.

12. **Poor internet / offline support**
    - App should work in poor internet areas.
    - Offline draft saving is required for profile creation.

13. **Image optimization**
    - Profile photos and work photos should be automatically compressed to save data.

14. **Invite/share**
    - Users should be able to share invites through WhatsApp and other apps to bring job workers, businesses, and skilled workers onto the platform.

15. **Assisted registration**
    - Assisted registration by admin/customer support over phone is desired later.
    - Not required at the start of demo/launch.

### Open Items From Round 6

- Decide whether offline support is limited to profile drafts or also cached search/profile viewing.
- Decide if profile completeness equals verified eligibility or automatically grants verification after admin/KYC checks.
- Decide detailed home-screen variations for each role.
- Decide whether "add work needed/wanted" is a lightweight post, profile field, or both depending on persona.
- Decide final translation management process and who approves Gujarati/Hindi textile terms.

## Round 7: Scale, Performance, Data, Reliability

### Confirmed Answers

1. **Year-1 scale target**
   - Design for 2,000 to 5,000 users in year 1.

2. **Long-term scale target**
   - 50M+ users is a long-term target after many years.
   - Architecture should scale step-by-step without rewriting.
   - Do not overbuild for 50M immediately, but avoid choices that force a full rewrite.

3. **Profile photo limits**
   - Shop photos: 3 to 5 per profile.
   - Work photos: 4 to 10 per single work/service.
   - Job workers may have multiple different work/service entries, each with its own photos.

4. **Video support**
   - Only photos at first.
   - No profile/work videos in initial product.

5. **Profile/photo update frequency**
   - Users can update whenever they want.
   - Some verified fields become locked after verification, such as mobile number, Aadhaar/identity verification, and verified photos.

6. **Search performance**
   - Search results should feel instant.
   - Target: less than 1 second.

7. **Contact reveal reliability**
   - Contact reveal should happen only after server confirmation.
   - Do not reveal contact details only from local/offline state.

8. **Critical data**
   - Whole user profile is the most critical data and should never be lost.

9. **Search availability**
   - Search should be available.
   - The app depends strongly on search, so search downtime is a major product issue.

10. **Push notifications**
    - Push notifications are required from day one.

11. **Initial notification types**
    - OTP.
    - Verification status.
    - New matching work-needed post.

12. **SMS fallback**
    - SMS fallback is required for important messages.

13. **All-India location support**
    - Users from any location in India should be able to register from day one.
    - The app should support all-India location hierarchy from day one, even though Surat is the first priority market.

14. **GPS coordinates**
    - Exact GPS coordinates are not clearly required.
    - More research/design is needed because the app shows locality text, but may still need location proof, fraud prevention, and nearest-profile ranking.

15. **Analytics/search logs**
    - Analytics and search logs should be stored from day one.
    - This data should help improve search accuracy later.

### Open Items From Round 7

- Decide whether exact GPS is captured only during verification, stored privately, rounded to approximate area, or not stored.
- Decide year-1 performance SLOs beyond search: profile open, image load, OTP, contact reveal, registration.
- Decide profile/media backup policy and restore target.
- Decide whether search should have a degraded fallback if the search engine/projection fails.
- Decide how many work/service entries one job-worker profile can have at launch.
- Decide whether verified photos are locked permanently or only require re-approval when changed.

## Round 8: Security, Privacy, Legal, Data Access

### Confirmed Answers

1. **Profile visibility during launch**
   - During launch/demo, everyone can see other profiles.
   - Launch mode is intentionally open to encourage adoption and profile creation.

2. **Exact address and contact reveal**
   - Exact address and contact number should be revealed together.
   - They are treated as locked contact details in the paid phase.

3. **Unverified users in paid phase**
   - During the paid phase, unverified users should not be able to see verified profiles' contact details.

4. **Temporary profile hiding**
   - Not required initially.
   - Can be added later.

5. **Blocking users**
   - Not required initially.
   - Can be added later.

6. **Login security**
   - Mobile OTP only.

7. **One account per mobile**
   - One mobile number should have only one account.

8. **Screenshot/copy restriction**
   - Screenshot/photo capture should be restricted where possible.
   - This is especially relevant around contact details and profile/contact reveal screens.

9. **Admin audit logs**
   - Admin actions should be logged.
   - Important examples: who approved a profile, who reviewed verification data, and who changed status.

10. **Developer/database access**
    - Full access is acceptable during early development.
    - This may need to tighten before launch/scale.

11. **Aadhaar/KYC provider model**
    - Research required.
    - Founder is not sure whether to use third-party verification and store only verification result/token instead of raw Aadhaar documents.

12. **Photo moderation**
    - Unsafe/inappropriate photo checks can be added later.
    - Not required in the initial product.

13. **Privacy policy, terms, consent**
    - Required before launch.
    - Can be handled later in the development process but must be ready before public launch.

14. **Separate contact reveal analytics consent**
    - Not required as a separate product flow.

15. **Age restriction**
    - No age restriction in the initial product.
    - Can be added later.

### Open Items From Round 8

- Research Indian privacy/legal requirements for account deletion, consent, personal data retention, and contact reveal analytics.
- Research Aadhaar/KYC legality and whether the app should avoid storing raw Aadhaar data.
- Decide whether screenshot restriction is technically enforceable enough on Android/iOS and where to apply it.
- Decide whether developer/database access must be restricted before launch even if full access is acceptable during early development.
- Decide the exact rule for "unverified users cannot see verified profiles" in paid phase: hide profile entirely, hide contact only, or show limited verified profile preview.
- Decide whether OTP-only login is enough once paid plans and sensitive verification data exist.

## Round 9: Data Model and Core Objects

### Confirmed Answers

1. **Account-to-profile model**
   - One user account has exactly one profile.

2. **Persona B work sections**
   - Persona B should be able to add work entries in a work section.
   - Each work type should be stored separately.
   - Search should search inside these work sections.
   - If a work entry matches the user query, the app should return that specific work entry in search results.
   - If the user likes that work, they can open the job worker's full profile.

3. **Persona A manufacture/sell fields**
   - Support both selected categories and free text.

4. **Manufacturer work-needed post fields**
   - Work type.
   - Product type.
   - Categories that the work belongs to.
   - Photos: 3 to 5.
   - More research is needed to decide the full field set.

5. **Work-needed post expiry**
   - Do not automatically expire/remove posts initially.
   - User removes the post when they find a job worker or no longer need the work.
   - More research is needed.
   - Study Internshala/Naukri-style job requirement posting and expiry/closing patterns for inspiration, while recognizing this app is not a job board or order-management system.

6. **Rating eligibility**
   - Users can rate only after contact reveal.

7. **Review content**
   - Text review.
   - Star rating.
   - No review photos confirmed.

8. **Review replies**
   - Users may be able to reply to reviews later.
   - Not needed in the initial product.

9. **Profile status values**
   - Profile status values are needed.
   - Can be added later, but architecture should account for statuses such as draft, active, unverified, verification pending, verified, rejected, and suspended.

10. **Profile completeness and ranking**
    - Profile completeness affects search ranking.
    - Complete and verified profiles should rank first.

11. **Admin-editable service categories**
    - Service categories should be editable from the admin panel.

12. **Service aliases/local names**
    - Service categories should support aliases and local names.
    - Examples: flat hemming, pico, hemming, Gujarati/Hindi variants.

13. **Search query logs**
    - Store every search query for analytics and future search improvement.

14. **Contact reveal history**
    - Store who revealed whose contact and when.
    - The event should be stored when the user clicks the show/reveal button on the profile/contact area.

15. **Admin export**
    - Admin should be able to export data to Excel/CSV.

### Open Items From Round 9

- Define full schema for work/service entries, especially machine type, product type, process type, photos, proof, and aliases.
- Define full schema for work-needed posts and whether posts should support status values such as open, paused, closed, expired, removed.
- Research Internshala/Naukri-style post lifecycle, closing, expiry, and admin moderation patterns for adaptation.
- Define review anti-abuse rules since ratings are contact-reveal based, not order-completion based.
- Decide whether profile statuses are needed from day one for admin and verification, even if user-facing status UI comes later.
- Decide CSV/Excel export scope and privacy restrictions.

## Round 10: Tech, Team, Budget, Hosting

### Confirmed Answers

1. **Builder/team**
   - The founder is building mostly by himself with Codex/AI help.

2. **Mobile technology preference**
   - Founder prefers Flutter + Dart.
   - The final app technology should still be re-evaluated during system design based on product/system needs.

3. **Backend language preference**
   - No backend language preference.

4. **Backend complexity preference**
   - Prefer simple and fast to build.
   - Avoid choices that create a wall later; research and evaluate before selecting.

5. **Infrastructure budget**
   - Not decided.

6. **Hosting preference**
   - Not decided.
   - Research needed to choose the best and cheapest option for the product needs.

7. **Database hosting**
   - Starting direction: cloud-based database.
   - Research needed before final choice.

8. **Vendor lock-in vs speed**
   - No fixed answer yet.
   - Avoid getting trapped by vendor limitations.
   - Speed is also important.
   - Research required to balance both.

9. **Staging/test environment**
   - No fixed requirement yet.
   - Research needed.

10. **Automatic backups**
    - Not requested initially by founder.
    - This may still be required architecturally because the whole user profile is critical data.

11. **Admin dashboard architecture**
    - Not decided.
    - Need to think whether admin dashboard uses the same backend or a separate internal tool.

12. **Analytics dashboard**
    - Analytics should be inside admin.

13. **Search engine**
    - Start with PostgreSQL search.
    - Search is core, so it should be improved quickly.
    - Dedicated search engine can be considered later when justified.

14. **AI features**
    - No AI features at launch.
    - AI/category mapping/translation/voice can be added later.

15. **System design scope**
    - Final system design should focus on MVP, not long-term 50M future architecture.
    - MVP should still avoid dead-end decisions that force a rewrite.

### Open Items From Round 10

- Research best low-cost hosting path for a solo founder building in India.
- Decide final app stack after architecture evaluation: Flutter/Dart vs alternatives.
- Decide backend stack with solo-builder speed and future migration in mind.
- Decide whether staging is necessary before launch even if not required by founder initially.
- Decide backup policy despite "not initially requested", because profile data is critical.
- Decide whether admin analytics can be built in the same admin app or should start from database/BI exports.

## Round 11: Final MVP Scope and Launch Rules

### Confirmed Answers

1. **MVP personas**
   - MVP must support all three personas:
     - Persona A: manufacturers / wholesalers / traders.
     - Persona B: job workers / value adders / workshops.
     - Persona C: skilled workers / karigars.

2. **Verified blue tick**
   - MVP should use admin manual status first.
   - Full provider-backed blue tick verification can come later.

3. **Subscription/payment**
   - Do not build active subscription/payment in the MVP.
   - Prepare the database and architecture so subscriptions can be added later.

4. **Contact reveal limits**
   - MVP launch mode should be unlimited/free.

5. **Manufacturer work-needed posts**
   - Include work-needed posts by manufacturers in the MVP.

6. **Ratings/reviews**
   - Ratings/reviews should be added later.
   - Not part of MVP.

7. **Customer support**
   - Customer support chat/call should be added later.
   - Not part of MVP.

8. **Admin dashboard**
   - Founder wants full admin control.
   - MVP architecture should include admin control, though exact implementation may need prioritization.

9. **KYC/Aadhaar/GST verification**
   - MVP should use manual document/status upload first.
   - Continue researching real provider integrations in parallel/later.

10. **Languages**
    - Internal/demo version can be English first.
    - Prepare translation structure for future Hindi/Gujarati UI.

11. **Search**
    - Start with exact/category search.
    - Improve quickly after MVP because search is core.

12. **Offline draft saving**
    - Offline draft saving can come later.
    - Not part of MVP.

13. **Push notifications**
    - Push notifications required from day one.

14. **MVP timeline**
    - Target: complete MVP in 3 weeks.

15. **Final deliverable**
    - One complete system design.

### Open Items From Round 11

- Decide whether "full admin control" in a 3-week MVP means complete custom admin UI or a phased admin approach with critical controls first.
- Decide whether manual document/status upload means users upload identity/GST/shop proof files in MVP, or admin manually marks statuses based on offline checks.
- Decide minimum viable search quality for launch: exact category only, keyword search, typo tolerance, alias matching, or multilingual aliases.
- Decide whether push notifications in MVP are only system notifications or also matching work-needed alerts.
- Decide whether database fields for subscriptions/contact limits should be built even though monetization is disabled in launch mode.

## Round 12: Final MVP Architecture Lock

### Confirmed Answers

1. **MVP admin scope**
   - Use a basic admin dashboard first.
   - Basic admin dashboard should include profile approval, manual verification, categories, analytics, and user/profile management.
   - Full platform admin control remains the long-term direction, but not all of it must be built in the 3-week MVP.

2. **MVP verification evidence**
   - Users should upload photos/documents in the app.
   - Admin manually reviews uploaded proof and updates verification status.

3. **MVP search quality**
   - Minimum MVP search: category + keyword + aliases/local terms.
   - Typo-tolerant multilingual search can improve after MVP.

4. **MVP push notifications**
   - Push notifications should include only verification/status messages.
   - Matching work-needed post alerts are not required in MVP.

5. **MVP contact/address visibility**
   - During MVP/private launch, exact address and contact should be fully visible.
   - Contact reveal locking can be enabled later.

6. **MVP contact analytics visibility**
   - Contact reveal analytics should be invisible to users during MVP.
   - The system may still record reveal/view events for admin analytics and future monetization design.

7. **Admin-created seed profiles**
   - Admin-created seed profiles should be marked as added by admin for testing/demo purposes.
   - After launch, full data should be entered by users only.

8. **MVP mobile platform**
   - Android first.
   - iOS is not required for MVP.

9. **MVP launch audience**
   - Private demo/testing with selected Surat users.
   - Not a broad public launch.

10. **Final design artifact**
    - Create the final system design as a new Markdown file under `outputs/`.
    - Use this discovery file as the source of truth.

### Remaining Research / Design Items Before Final System Design

- Research Aadhaar/KYC and decide a safe MVP approach around proof uploads and stored verification status.
- Research GST verification feasibility enough to design the future integration boundary.
- Research low-cost hosting/database/storage options suitable for a solo founder and Android MVP in India.
- Research or reason from comparable posting flows such as Internshala/Naukri for work-needed post lifecycle, while keeping the MVP simple.
- Finalize MVP architecture, database schema, API surface, admin scope, search strategy, media flow, notification flow, security controls, and ADRs.
