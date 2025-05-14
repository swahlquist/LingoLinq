# LingoLinq API v1 Documentation

This document outlines the available API endpoints for LingoLinq v1.

**Base URL:** `/api/v1`

## Authentication

Most endpoints require an API token for authentication. The token should be passed in the request headers. Some specific public-facing endpoints or actions initiated via special links (e.g., password reset) might have exceptions.

---

## Resources

### 1. Badges

Manages user badges, which can represent achievements or earned recognitions.

* **`GET /users/:user_id/badges`**
    * **Description:** Retrieves a list of badges for a specific user. Can be filtered by `recent`, `goal_id`, `highlighted`, and `earned`.
    * **Permissions:** Requires viewing rights for the user's detailed information. Supervisors can see all badges; others might see only highlighted or non-superseded ones.
* **`GET /badges/:id`**
    * **Description:** Retrieves a specific badge by its ID.
    * **Permissions:** Requires viewing rights for the badge.
* **`PUT /badges/:id`**
    * **Description:** Updates a specific badge.
    * **Parameters:** `badge` (object containing badge attributes to update).
    * **Permissions:** Requires editing rights for the badge.

### 2. Boards

Manages communication boards, which are central to the application. Boards contain buttons and content for users.

* **`GET /boards`**
    * **Description:** Retrieves a list of boards. Can be filtered by `user_id`, `key`, `q` (query), `locale`, `sort` (e.g., `popularity`, `home_popularity`), `public`, `private`, `starred`, `tag`, `category`, `include_shared`, and `exclude_starred`.
    * **Permissions:** Varies based on parameters. Public boards are generally accessible. Access to user-specific or private boards requires appropriate permissions (e.g., 'view_detailed', 'model').
* **`POST /boards`**
    * **Description:** Creates a new board. Can be created for the API user or another user if permissions allow ('edit' on the target user).
    * **Parameters:** `board` (object containing board attributes like `key`, `for_user_id`, `parent_board_id`, grid details, buttons, etc.).
    * **Permissions:** API user creating the board. If `for_user_id` is specified, 'edit' permission on that user is needed.
* **`GET /boards/:id`**
    * **Description:** Retrieves a specific board by its ID or user_name/key path. Tracks usage of the board.
    * **Permissions:** Requires 'view' permission for the board.
* **`PUT /boards/:id`**
    * **Description:** Updates a specific board or a button within a board. Can also undelete a board under certain conditions.
    * **Parameters:** `board` (object with board attributes) or `button` (object with button attributes).
    * **Permissions:** Requires 'edit' permission for the board.
* **`DELETE /boards/:id`**
    * **Description:** Deletes a specific board. If it's a shallow clone root, it might be unstarred or removed from replaced roots.
    * **Permissions:** Requires 'delete' permission for the board, or 'edit' if it's a sub-board being unstarred.
* **`GET /boards/:board_id/stats`**
    * **Description:** Retrieves usage statistics for a board.
    * **Permissions:** Requires 'view' permission for the board.
* **`POST /boards/imports`**
    * **Description:** Imports a board from a URL or initiates a remote upload for an OBF/OBZ file.
    * **Parameters:** `url` (for direct import) or `type` (`obf`/`obz` for initiating upload).
* **`POST /boards/:board_id/stars`**
    * **Description:** Stars a board for the API user.
    * **Permissions:** Requires 'view' permission for the board and an authenticated API user.
* **`DELETE /boards/:board_id/stars`**
    * **Description:** Unstars a board for the API user.
    * **Permissions:** Requires 'view' permission for the board and an authenticated API user.
* **`POST /boards/:board_id/download`**
    * **Description:** Initiates a background job to generate a downloadable version of the board (e.g., PDF, OBF).
    * **Parameters:** `type`, `include`, `headerless`, `text_on_top`, `transparent_background`, `symbol_background`, `text_only`, `text_case`, `font`.
    * **Permissions:** Requires 'view' permission for the board.
* **`POST /boards/:board_id/rename`**
    * **Description:** Renames a board by changing its key.
    * **Parameters:** `new_key`, `old_key`.
    * **Permissions:** Requires 'edit' permission for the board.
* **`POST /boards/:board_id/translate`**
    * **Description:** Initiates a background job to translate a board and optionally other related boards.
    * **Parameters:** `translations` (object), `source_lang`, `destination_lang`, `fallbacks`, `board_ids_to_translate`, `set_as_default`.
    * **Permissions:** Requires 'edit' permission for the board.
* **`POST /boards/:board_id/swap_images`**
    * **Description:** Initiates a background job to swap images on a board (and related boards) to a specified library.
    * **Parameters:** `library`, `board_ids_to_convert`, `include_new`.
    * **Permissions:** Requires 'edit' permission for the board.
* **`POST /boards/:board_id/privacy`**
    * **Description:** Initiates a background job to update the privacy settings for a board (and related boards).
    * **Parameters:** `privacy` (setting), `board_ids_to_update`.
    * **Permissions:** Requires 'edit' permission for the board.
* **`POST /boards/:board_id/tag`**
    * **Description:** Tags a board for the API user.
    * **Parameters:** `tag`, `remove` (boolean), `downstream` (boolean).
    * **Permissions:** Requires 'view' permission for the board.
* **`POST /boards/:board_id/rollback`**
    * **Description:** Rolls back a board to a previous version based on a date. Can also restore a deleted board.
    * **Parameters:** `date`.
    * **Permissions:** Requires 'edit' permission on the board or 'admin_support_actions'. For deleted boards, 'view_deleted_boards' on the user.
* **`GET /boardversions?board_id=:board_id`** (linked from `GET /boards/:board_id/history` in some contexts)
    * **Description:** Retrieves the version history for a specific board.
    * **Permissions:** Requires 'edit' permission on the board or 'admin_support_actions'. For deleted boards, 'view_deleted_boards' on the user.

### 3. Button Sets

Manages pre-defined sets of buttons that can be applied to boards.

* **`GET /buttonsets?user_id=:user_id`**
    * **Description:** Retrieves button sets available to a user.
    * **Permissions:** Requires 'model' permission on the user.
* **`GET /buttonsets/:id`**
    * **Description:** Retrieves a specific button set (often linked to a board).
    * **Permissions:** Requires 'view' permission on the associated board.
* **`POST /buttonsets/:id/generate`**
    * **Description:** Generates or retrieves the URL for a button set if it exists and is up-to-date. If `missing=true` is passed, it forces regeneration if the private CDN URL was recently checked.
    * **Parameters:** `missing` (boolean, optional).
    * **Permissions:** Requires 'view' permission on the associated board.

### 4. Callbacks

Handles callbacks from external services, primarily AWS SNS.

* **`POST /callback`**
    * **Description:** Processes incoming notifications from AWS SNS. Handles subscription confirmations and notifications for services like audio/video transcoding and inbound SMS.
    * **Headers:** Expects `x-amz-sns-topic-arn` and `x-amz-sns-message-type`.
    * **Security:** Validates SNS topic ARN and message authenticity for certain types.

### 5. Gifts

Manages gift codes for subscriptions or features.

* **`GET /gifts`**
    * **Description:** Retrieves all gift purchases.
    * **Permissions:** Requires 'admin_support_actions'.
* **`POST /gifts`**
    * **Description:** Creates a new gift purchase/code.
    * **Parameters:** `gift` (object with attributes like `licenses`, `total_codes`, `amount`, `expires`, `limit`, `code`, `memo`, `email`, `organization_id`, `gift_type`, etc.).
    * **Permissions:** Requires 'admin_support_actions'.
* **`GET /gifts/:id`** or **`GET /gifts/:id::verifier`**
    * **Description:** Retrieves a specific gift purchase by its code (ID). A verifier can be used for codes shorter than 20 characters if not an admin.
    * **Permissions:** Requires 'view' permission on the gift. Admin can bypass verifier.
* **`DELETE /gifts/:id`**
    * **Description:** Deactivates a gift purchase.
    * **Permissions:** Requires 'admin_support_actions'.
* **`GET /gifts/code_check?code=:code`**
    * **Description:** Checks the validity and details of a gift code for redemption.
    * **Parameters:** `code`.
    * **Response:** `{valid: boolean, error: string, type: string, discount_percent: number, extras: boolean, supporters: boolean}`.

### 6. Goals

Manages user goals and templates for goals.

* **`GET /goals?user_id=:user_id`**
    * **Description:** Retrieves goals for a user. Can be filtered by `active`, `template`.
    * **Permissions:** Requires 'supervise' permission on the user. If fetching templates for a user, 'delete' permission is also needed.
* **`GET /goals?template_header=true`**
    * **Description:** Retrieves goal template headers.
* **`GET /goals?global=true`**
    * **Description:** Retrieves global goal templates.
* **`GET /goals?template_header_id=:template_header_id`**
    * **Description:** Retrieves goals linked to a specific template header.
* **`POST /goals`**
    * **Description:** Creates a new goal for a user.
    * **Parameters:** `goal` (object with attributes like `user_id`, `template_header`, etc.).
    * **Permissions:** Requires 'set_goals' on the user. If `template_header` is true, 'edit' on admin organization is needed.
* **`GET /goals/:id`**
    * **Description:** Retrieves a specific goal.
    * **Permissions:** Requires 'view' permission on the goal.
* **`PUT /goals/:id`**
    * **Description:** Updates a goal. If user only has 'comment' permission, only comments can be updated.
    * **Parameters:** `goal` (object with attributes to update).
    * **Permissions:** Requires 'comment' permission. 'Edit' permission needed for full update.
* **`DELETE /goals/:id`**
    * **Description:** Deletes a goal.
    * **Permissions:** Requires 'edit' permission on the goal.

### 7. Images

Manages images that can be used on buttons.

* **`POST /images`**
    * **Description:** Creates a new button image. Can initiate a remote upload.
    * **Parameters:** `image` (object with attributes like `content_type`, and other image details). `content_type` is required.
* **`GET /images/:id`**
    * **Description:** Retrieves a specific button image. Supports preferred symbol sources and inclusion of other sources based on user permissions.
    * **Permissions:** Requires 'view' permission for the image.
* **`PUT /images/:id`**
    * **Description:** Updates a button image.
    * **Parameters:** `image` (object with attributes to update).
    * **Permissions:** Requires 'view' permission (likely 'edit' intended based on pattern, but controller says 'view').
* **`GET /images/batch?ids=:ids`**
    * **Description:** Retrieves a batch of images by their IDs (not explicitly defined in routes but present in controller `index` action, typically `GET /images` with query params).
* **`GET /images/:id/upload_success`**
    * **Description:** Callback URL for successful remote image uploads (likely S3).

### 8. Integrations

Manages user integrations with external services or features.

* **`GET /integrations?user_id=:user_id`**
    * **Description:** Retrieves integrations for a user or global template integrations. Can filter by `for_button`.
    * **Permissions (for user_id):** Requires 'supervise' permission on the user.
* **`POST /integrations`**
    * **Description:** Creates or updates an integration for a user, potentially based on a template.
    * **Parameters:** `integration` (object with `user_id`, `integration_key`, and other settings).
    * **Permissions:** Requires 'supervise' permission on the user.
* **`GET /integrations/:id`**
    * **Description:** Retrieves a specific integration.
    * **Permissions:** Requires 'view' permission on the integration.
* **`PUT /integrations/:id`**
    * **Description:** Updates an integration.
    * **Parameters:** `integration` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission on the integration.
* **`DELETE /integrations/:id`**
    * **Description:** Deletes an integration.
    * **Permissions:** Requires 'delete' permission on the integration.
* **`GET /domain_settings`**
    * **Description:** Retrieves domain-specific override settings.
* **`POST /focus/usage`**
    * **Description:** Tracks the usage of a "focus" item (related to OpenAAC workshop content).
    * **Parameters:** `focus_id`.

### 9. Lessons

Manages educational lessons and assignments.

* **`GET /lessons`**
    * **Description:** Retrieves lessons. Can be filtered by `user_id`, `organization_id`, `organization_unit_id`. Without these, lists public lessons.
    * **Permissions (for user/org/unit specific):** Requires 'supervise' (user) or 'edit' (org/unit).
* **`POST /lessons`**
    * **Description:** Creates a new lesson and can assign it to an initial target (user, org, or unit).
    * **Parameters:** `lesson` (object with attributes like `organization_id`, `user_id`, `target_types`, etc.).
    * **Permissions:** Requires 'edit' (org/unit) or 'supervise' (user) on the initial target.
* **`GET /lessons/:id`** or **`GET /lessons/:lesson_id::lesson_code::user_token`**
    * **Description:** Retrieves a specific lesson, potentially using a nonce/code for access.
    * **Permissions:** Requires 'view' permission or valid lesson code and user token.
* **`PUT /lessons/:id`**
    * **Description:** Updates a lesson.
    * **Parameters:** `lesson` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission on the lesson.
* **`DELETE /lessons/:id`** (mapped via `destroy` action for `params['lesson_id']`)
    * **Description:** Deletes a lesson.
    * **Permissions:** Requires 'delete' permission on the lesson.
* **`POST /lessons/:lesson_id/assign`**
    * **Description:** Assigns a lesson to a user, organization, or unit.
    * **Parameters:** `user_id` OR `organization_id` OR `organization_unit_id`.
    * **Permissions:** Requires 'view' on lesson, and 'supervise' (user) or 'edit' (org/unit) on target.
* **`POST /lessons/:lesson_id/unassign`**
    * **Description:** Unassigns a lesson from a user, organization, or unit.
    * **Parameters:** `user_id` OR `organization_id` OR `organization_unit_id`.
    * **Permissions:** Requires 'view' on lesson, and 'supervise' (user) or 'edit' (org/unit) on target.
* **`POST /lessons/:lesson_id/complete`**
    * **Description:** Marks a lesson as complete for a user, using a lesson code and user token for access.
    * **Parameters:** `rating`, `duration`. `lesson_id` in the path is `lesson_id::lesson_code::user_token`.
    * **Permissions:** Requires valid lesson code and user token.
* **`GET /lessons/:lesson_id/recent`**
    * **Description:** List of lessons recently authored by the user or their org or unit (details of implementation not fully clear in controller).

### 10. Logs

Manages user activity logs and sessions.

* **`GET /users/:user_id/logs`**
    * **Description:** Retrieves logs for a user. Can be filtered by `supervisees`, `type` (session, note, assessment, etc.), `highlighted`, `goal_id`, `location_id`, `device_id`, `start`, `end`.
    * **Permissions:** Requires 'supervise' on the user. Subject to logging privacy settings and codes.
* **`POST /users/:user_id/logs`** (mapped via `create` for `params['log']` which contains `user_id`)
    * **Description:** Creates a new log session or entry.
    * **Parameters:** `log` (object with log details, `user_id`).
    * **Permissions:** Requires 'model' permission on the user.
* **`GET /logs/:id`**
    * **Description:** Retrieves a specific log session.
    * **Permissions:** Requires 'supervise' on the log's user, subject to logging privacy.
* **`PUT /logs/:id`**
    * **Description:** Updates a log session.
    * **Parameters:** `log` (object with attributes to update).
    * **Permissions:** Requires 'supervise' on the log's user, subject to logging privacy.
* **`POST /logs/import?user_id=:user_id`**
    * **Description:** Imports logs for a user from a URL/content or initiates a remote upload.
    * **Parameters:** `url` or `content`, `type` (`obl`, `lam`). If no `url`/`content`, initiates upload.
    * **Permissions:** Requires 'supervise' on the user.
* **`GET /logs/:log_id/lam?nonce=:nonce`**
    * **Description:** Retrieves log data in LAM format if nonce matches. (Publicly accessible with correct nonce).
* **`GET /logs/obl?log_id=:log_id` or `GET /logs/obl?user_id=:user_id`**
    * **Description:** Initiates an OBL export for a specific log or all logs for a user.
    * **Parameters:** `log_id` or `user_id`, `anonymized` (boolean for user export).
    * **Permissions:** Requires 'supervise' on the user, subject to logging privacy.
* **`POST /logs/code_check?user_id=:user_id`**
    * **Description:** Checks if a provided logging code is valid for a user.
    * **Parameters:** `code`.
    * **Permissions:** Requires 'supervise' on the user, subject to logging privacy.
* **`GET /logs/trends`**
    * **Description:** Retrieves global statistic trends. Cached. Admin users see more data. (Publicly accessible).
* **`GET /logs/trends_slice`**
    * **Description:** Retrieves trends for a slice of users, authenticated by an integration key/secret.
    * **Parameters:** `integration_id`, `integration_secret`, `user_ids` (comma-separated).
* **`GET /logs/anonymous_logs`**
    * **Description:** Retrieves a URL for downloading anonymous log data. (Publicly accessible, cached).

### 11. Messages

Handles creation of contact messages (support tickets).

* **`POST /messages`**
    * **Description:** Creates a new contact message.
    * **Parameters:** `message` (object with message details like subject, body, email etc.).
    * **Permissions:** Requires API token OR if `ENV['ALLOW_UNAUTHENTICATED_TICKETS']` is true.

### 12. Organizations

Manages organizations, their users, settings, and related data.

* **`GET /organizations`**
    * **Description:** Retrieves a list of all organizations.
    * **Permissions:** Requires 'edit' permission on the admin organization.
* **`POST /organizations`**
    * **Description:** Creates a new organization.
    * **Parameters:** `organization` (object with organization attributes).
    * **Permissions:** Requires 'manage' permission on the admin organization.
* **`GET /organizations/:id`**
    * **Description:** Retrieves a specific organization.
    * **Permissions:** Requires 'view' permission on the organization.
* **`PUT /organizations/:id`**
    * **Description:** Updates an organization. Certain fields require higher privileges like 'update_licenses' or 'delete'.
    * **Parameters:** `organization` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission. Specific attributes require 'update_licenses' or 'delete'.
* **`DELETE /organizations/:id`**
    * **Description:** Deletes an organization.
    * **Permissions:** Requires 'delete' permission on the organization.
* **`GET /organizations/:organization_id/users`**
    * **Description:** Retrieves users associated with an organization.
    * **Permissions:** Requires 'edit' permission on the organization.
* **`GET /organizations/:organization_id/managers`**
    * **Description:** Retrieves managers of an organization.
    * **Permissions:** Requires 'edit' permission on the organization.
* **`GET /organizations/:organization_id/supervisors`**
    * **Description:** Retrieves supervisors in an organization.
    * **Permissions:** Requires 'edit' permission on the organization.
* **`GET /organizations/:organization_id/stats`**
    * **Description:** Retrieves usage statistics for an organization.
    * **Permissions:** Requires 'edit' permission on the organization.
* **`GET /organizations/:organization_id/logs`**
    * **Description:** Retrieves log sessions associated with an organization.
    * **Permissions:** Requires 'manage' permission on the organization.
* **`POST /organizations/:organization_id/start_code`**
    * **Description:** Creates or deletes a start code for an organization.
    * **Parameters:** `delete` (boolean), `code` (for deletion), `overrides` (for creation).
    * **Permissions:** Requires 'edit' permission on the organization.
* **`GET /start_code?code=:code`** (Global, not namespaced under an org ID in routes)
    * **Description:** Looks up an activation/start code to get its details.
    * **Parameters:** `code`, `v` (verifier).
    * **Permissions:** Valid verifier, or 'edit' permission on the target user/org by the API user.
* **`POST /organizations/:organization_id/status/:user_id`**
    * **Description:** Sets the status of a user within an organization.
    * **Parameters:** `status` (object with `state` and optional `note`).
    * **Permissions:** Supervisor or manager of the org, or 'manage' on the org. 'Supervise' on the user.

### 13. Profiles

Manages user profile templates and instances (often stored as logs).

* **`GET /profiles?user_id=:user_id`**
    * **Description:** Retrieves profile templates available to a user (static, global, and org-specific).
    * **Permissions:** Requires 'supervise' permission on the user.
* **`GET /profiles/:id`**
    * **Description:** Retrieves a specific profile template by code or static ID.
    * **Permissions:** Requires 'view' permission on the profile template.
* **`GET /profiles/latest?user_id=:user_id`**
    * **Description:** Retrieves the latest profile sessions (logs of type 'profile') for a user. Can filter by `profile_id`. Includes suggestions if `include_suggestions=true`.
    * **Parameters:** `user_id`, `profile_id` (optional), `include_suggestions` (optional boolean).
    * **Permissions:** Requires 'supervise' permission on the user.

### 14. Progress

Tracks the status of background jobs.

* **`GET /progress/:id`**
    * **Description:** Retrieves the status of a specific background job.
    * **Permissions:** Requires 'view' permission on the progress item (likely linked to the user who initiated it).

### 15. Purchasing

Handles purchasing events and gift code management related to payments.

* **`POST /purchasing_event`**
    * **Description:** Handles subscription events from a payment provider (e.g., Stripe webhook).
* **`GET /gifts/code_check?code=:code`** (also listed under Gifts, controller is PurchasingController)
    * **Description:** Checks the validity of a gift code.
    * **Parameters:** `code`.
* **`POST /purchase_gift`**
    * **Description:** Processes a gift purchase using a payment token.
    * **Parameters:** `token` (payment token object), `type`, `code` (optional gift code being used), `email`, `extras`, `supporters`, `donate`.

### 16. Search

Provides various search functionalities.

* **`GET /search/symbols?q=:query`**
    * **Description:** Searches for symbols via OpenSymbols.org. Supports `locale` and `safe` search. Can search premium repos like `pcs` and `symbolstix` if user has permissions.
    * **Parameters:** `q`, `locale`, `safe`, `user_name` (for premium repo context).
* **`GET /search/protected_symbols?q=:query&library=:library`**
    * **Description:** Searches for symbols in protected libraries (e.g., Giphy ASL).
    * **Parameters:** `q`, `library`, `user_name` (for user context).
* **`GET /search/external_resources?q=:query&source=:source`**
    * **Description:** Searches for external resources from various sources.
    * **Parameters:** `q`, `source`, `user_name` (for user context).
* **`GET /search/proxy?url=:url`**
    * **Description:** Proxies a request to an external URL to fetch content (images, audio, json) and return it base64 encoded.
    * **Parameters:** `url`.
* **`GET /search/parts_of_speech?q=:word`**
    * **Description:** Retrieves parts of speech and other linguistic data for a word. Includes suggestions if `suggestions=true`.
    * **Parameters:** `q` (word), `suggestions` (boolean).
* **`GET /search/apps?q=:query&os=:os`**
    * **Description:** Searches for applications based on a query and operating system.
    * **Parameters:** `q`, `os`.
* **`GET /search/audio?text=:text&locale=:locale`**
    * **Description:** Synthesizes speech using a TTS engine (e.g., Google Translate, Abair.ie for Irish).
    * **Parameters:** `text`, `locale`, `voice_id` (optional), `mp3` (boolean, for Google TTS).
* **`GET /search/focus?locale=:locale&q=:query`**
    * **Description:** Searches for "focus" items from workshop.openaac.org.
    * **Parameters:** `locale`, `q`, `category`, `type`, `sort`.

### 17. Snapshots

Manages snapshots of user log data.

* **`GET /users/:user_id/snapshots`**
    * **Description:** Retrieves snapshots for a user.
    * **Permissions:** Requires 'supervise' permission on the user.
* **`POST /snapshots`**
    * **Description:** Creates a new log snapshot for a user.
    * **Parameters:** `snapshot` (object with `user_id` and snapshot details).
    * **Permissions:** Requires 'edit' permission on the user.
* **`GET /snapshots/:id`**
    * **Description:** Retrieves a specific snapshot.
    * **Permissions:** Requires 'view' permission on the snapshot (implicitly via user).
* **`PUT /snapshots/:id`**
    * **Description:** Updates a snapshot.
    * **Parameters:** `snapshot` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission on the snapshot.
* **`DELETE /snapshots/:id`**
    * **Description:** Deletes a snapshot.
    * **Permissions:** Requires 'delete' permission on the snapshot.

### 18. Sounds

Manages sound recordings that can be attached to buttons.

* **`GET /users/:user_id/sounds`**
    * **Description:** Retrieves sounds uploaded by a specific user.
    * **Permissions:** Requires 'supervise' permission on the user.
* **`POST /sounds`**
    * **Description:** Creates a new button sound. Can be for the API user or another user if permissions allow. Can initiate remote upload.
    * **Parameters:** `sound` (object with sound details, optional `user_id`).
    * **Permissions (if for another user):** Requires 'supervise' on that user.
* **`GET /sounds/:id`**
    * **Description:** Retrieves a specific button sound.
    * **Permissions:** Requires 'view' permission for the sound.
* **`PUT /sounds/:id`**
    * **Description:** Updates a button sound.
    * **Parameters:** `sound` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission for the sound.
* **`DELETE /sounds/:id`**
    * **Description:** Deletes a button sound.
    * **Permissions:** Requires 'edit' permission for the sound.
* **`POST /sounds/imports?user_id=:user_id`**
    * **Description:** Imports sounds from a URL or initiates a remote upload of a ZIP file.
    * **Parameters:** `url` (for direct import). If no `url`, initiates upload.
* **`GET /sounds/:id/upload_success`**
    * **Description:** Callback URL for successful remote sound uploads.

### 19. Tags (NFC)

Manages NFC tags and their associated content.

* **`GET /tags?user_id=:user_id`**
    * **Description:** Retrieves NFC tags for a user (or API user if `user_id` omitted) that have content.
    * **Permissions (if user_id specified):** Requires 'model' permission on the user.
* **`POST /tags`**
    * **Description:** Creates a new NFC tag entry for the API user.
    * **Parameters:** `tag` (object with tag details).
    * **Permissions:** Requires 'supervise' permission on the API user (likely meaning they can manage their own tags).
* **`GET /tags/:id`**
    * **Description:** Retrieves an NFC tag by its global ID or physical tag ID. If by physical ID, prioritizes user's tag, then public ones.
    * **Permissions:** If tag is not public, requires 'model' permission on the tag's user.
* **`PUT /tags/:id`**
    * **Description:** Updates an NFC tag.
    * **Parameters:** `tag` (object with attributes to update).
    * **Permissions:** Requires 'supervise' permission on the tag's user.
* **`DELETE /tags/:id`**
    * **Description:** Deletes an NFC tag.
    * **Permissions:** Requires 'supervise' permission on the tag's user.

### 20. Units (Organization Units / Rooms)

Manages organizational units, often referred to as rooms.

* **`GET /organizations/:organization_id/units`**
    * **Description:** Retrieves units for an organization.
    * **Permissions:** Requires 'edit' permission on the organization.
* **`POST /units`**
    * **Description:** Creates a new organizational unit.
    * **Parameters:** `unit` (object with `organization_id` and unit details).
    * **Permissions:** Requires 'edit' permission on the parent organization.
* **`GET /units/:id`**
    * **Description:** Retrieves a specific organizational unit.
    * **Permissions:** Requires 'view' permission on the unit.
* **`PUT /units/:id`**
    * **Description:** Updates an organizational unit.
    * **Parameters:** `unit` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission on the unit.
* **`DELETE /units/:id`**
    * **Description:** Deletes an organizational unit.
    * **Permissions:** Requires 'delete' permission on the unit.
* **`GET /units/:unit_id/stats`**
    * **Description:** Retrieves usage statistics for a unit, including weekly user activity and supervisor modeling.
    * **Permissions:** Requires 'view_stats' permission on the unit.
* **`GET /units/:unit_id/log_stats`**
    * **Description:** Retrieves aggregated log statistics for a unit, like common words, modeled words, and goal words.
    * **Permissions:** Requires 'view_stats' permission on the unit.
* **`GET /units/:unit_id/logs`**
    * **Description:** Retrieves session logs for communicator users within a unit.
    * **Permissions:** Requires 'view_stats' permission on the unit.
* **`POST /units/:unit_id/note`**
    * **Description:** Sends a message (note) to users (communicators, supervisors, or all) within a unit. Can include video details and notification preferences.
    * **Parameters:** `note` (message text), `target` ('communicators', 'supervisors', 'all'), `video_id` (optional), `include_footer` (boolean), `notify_user` (boolean), `notify_exclude_ids`.
    * **Permissions:** Requires 'view_stats' permission on the unit.

### 21. Users

Manages user accounts, settings, and related actions.

* **`GET /users?q=:query&org_id=:org_id`**
    * **Description:** Searches for users by email, username, or global ID. Can be scoped to an organization if `org_id` is provided and user has permission.
    * **Permissions:** Requires 'admin_support_actions' or, if `org_id` is present, 'edit' on that organization.
* **`POST /users`**
    * **Description:** Creates a new user (registers). Can include a `start_code` for automated setup. Sends confirmation email.
    * **Parameters:** `user` (object with user attributes like `user_name`, `email`, `password`, `start_code`, etc.).
* **`GET /users/:id`**
    * **Description:** Retrieves a specific user's details.
    * **Permissions:** Requires 'view_existence' for the user, or if `confirmation` code matches user's registration code.
* **`PUT /users/:id`**
    * **Description:** Updates a user's details. Password changes require a valid `reset_token` or admin permissions. Limited updates possible with 'manage_supervision' permission.
    * **Parameters:** `user` (object with attributes to update), `reset_token` (optional).
    * **Permissions:** Usually 'edit'. 'support_actions' for admin password reset. 'manage_supervision' for supervisor_key updates.
* **`POST /users/:user_id/confirm_registration`**
    * **Description:** Confirms a user's registration with a code, or resends the confirmation email if `resend=true`.
    * **Parameters:** `code` (optional), `resend` (boolean, optional).
* **`POST /forgot_password`**
    * **Description:** Initiates password reset process by sending an email to the user(s) matching the key (username or email).
    * **Parameters:** `key`.
* **`POST /users/:user_id/password_reset`**
    * **Description:** Validates a password reset code and returns a reset token if valid.
    * **Parameters:** `code`.
* **`GET /users/:user_id/stats/daily`**
    * **Description:** Retrieves daily usage statistics for a user.
    * **Permissions:** Requires 'supervise' on the user.
* **`GET /users/:user_id/stats/hourly`**
    * **Description:** Retrieves hourly usage statistics for a user.
    * **Permissions:** Requires 'supervise' on the user.
* **`GET /users/:user_id/alerts`**
    * **Description:** Retrieves active (non-cleared) notification alerts for a user.
    * **Permissions:** Requires 'supervise' on the user.
* **`POST /users/:user_id/subscription`**
    * **Description:** Manages user subscriptions. Can redeem gift codes, apply admin overrides, or process payment tokens.
    * **Parameters:** `type` (e.g., 'gift_code', 'eval', 'add_1'), `token` (payment or gift code), `confirmation` (for initial registration subscription).
    * **Permissions:** Varies by `type`. 'edit' for most, 'admin_support_actions' for overrides. Registration confirmation for initial subscription.
* **`DELETE /users/:user_id/subscription`**
    * **Description:** Unsubscribes a user from their current plan.
    * **Parameters:** `reason` (optional).
    * **Permissions:** Requires 'edit' on the user.
* **`POST /users/:user_id/flush/logs`**
    * **Description:** Initiates a job to flush (delete) all logs for a user. Requires confirmation.
    * **Parameters:** `user_name`, `confirm_user_id`.
    * **Permissions:** Requires 'delete' on the user.
* **`GET /users/:user_id/supervisors`**
    * **Description:** Retrieves a list of supervisors for the user.
    * **Permissions:** Requires 'supervise' on the user.
* **`GET /users/:user_id/supervisees`**
    * **Description:** Retrieves a list of users supervised by this user.
    * **Permissions:** Requires 'supervise' on the user (to see their own supervisees).
* **`GET /users/:user_id/boards`**
    * **Description:** Retrieves a batch of boards by their IDs, ensuring the user has view permission.
    * **Parameters:** `ids` (comma-separated list of board IDs).
    * **Permissions:** Requires 'model' permission on the user.
* **`GET /userversions?user_id=:user_id`** (linked from `GET /users/:user_id/history` in some contexts)
    * **Description:** Retrieves the version history for a specific user.
    * **Permissions:** Requires 'admin_support_actions'.

### 22. Utterances

Manages user utterances (spoken phrases or messages).

* **`POST /utterances`**
    * **Description:** Creates a new utterance. Can be for the API user or another specified user.
    * **Parameters:** `utterance` (object with utterance details, optional `user_id`).
    * **Permissions (if for another user):** Requires 'model' permission on that user.
* **`GET /utterances/:id`** or **`GET /utterances/:utterance_id::reply_code`**
    * **Description:** Retrieves a specific utterance. Can be accessed via a reply code.
    * **Permissions:** Requires 'view' permission or a valid reply code.
* **`PUT /utterances/:id`**
    * **Description:** Updates an utterance.
    * **Parameters:** `utterance` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission on the utterance.
* **`POST /utterances/:utterance_id/share`**
    * **Description:** Shares an utterance with another user or via contact details (email/phone).
    * **Parameters:** `user_id` (target user) or `contact_type` and `contact_value`. `sharer_id` can specify the sharing user.
    * **Permissions:** Requires 'edit' on the utterance. If sharing as another user, 'model' on that sharer. Premium access may be required for sharing.
* **`POST /utterances/:utterance_id/reply`** (`utterance_id` in path is `utterance_id::reply_code`)
    * **Description:** Sends a reply to an utterance via a reply code. The reply is logged as a message to the original utterer from the user associated with the reply code.
    * **Parameters:** `message` (reply text).
    * **Permissions:** Valid reply code is required.

### 23. Videos

Manages user-uploaded videos.

* **`POST /videos`**
    * **Description:** Creates a new user video. Can initiate remote upload.
    * **Parameters:** `video` (object with video details).
* **`GET /videos/:id`**
    * **Description:** Retrieves a specific user video.
    * **Permissions:** Requires 'view' permission for the video.
* **`PUT /videos/:id`**
    * **Description:** Updates a user video.
    * **Parameters:** `video` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission for the video.
* **`GET /videos/:id/upload_success`**
    * **Description:** Callback URL for successful remote video uploads.

### 24. Webhooks

Manages webhooks for user event notifications.

* **`GET /users/:user_id/webhooks`**
    * **Description:** Retrieves webhooks for a user.
    * **Permissions:** Requires 'supervise' permission on the user.
* **`POST /webhooks`**
    * **Description:** Creates a new webhook.
    * **Parameters:** `webhook` (object with `user_id` and webhook details like URL, event types).
    * **Permissions:** Requires 'supervise' permission on the user for whom the webhook is created.
* **`PUT /webhooks/:id`**
    * **Description:** Updates a webhook.
    * **Parameters:** `webhook` (object with attributes to update).
    * **Permissions:** Requires 'edit' permission on the webhook.
* **`DELETE /webhooks/:id`**
    * **Description:** Deletes a webhook.
    * **Permissions:** Requires 'delete' permission on the webhook.
* **`POST /webhooks/:webhook_id/test`**
    * **Description:** Sends a test notification to the webhook.
    * **Permissions:** Requires 'edit' permission on the webhook.

### 25. Words (Word Data)

Manages linguistic data for words, primarily for admin use.

* **`GET /words?locale=:locale`**
    * **Description:** Retrieves word data for a locale, ordered for review. Can filter by a specific `word`.
    * **Permissions:** Requires 'admin_support_actions'.
* **`PUT /words/:id`**
    * **Description:** Updates word data (e.g., part of speech, definitions). Can mark a word to be skipped in reviews.
    * **Parameters:** `word` (object with attributes to update, or `skip` boolean).
    * **Permissions:** Requires 'admin_support_actions'.
* **`GET /lang/:locale`** (Global, not namespaced under `words` directly in routes file, but handled by WordsController)
    * **Description:** Retrieves language-specific rules (inflections, contractions) for a locale.
* **`GET /users/:user_id/words/reachable_core?utterance_id=:utterance_id`**
    * **Description:** Retrieves a list of "reachable core" words for a user. Access can also be granted via an utterance reply code if user allows utterance core access.
    * **Permissions:** Requires 'supervise' on the user, OR if `utterance_id` (with reply code) is provided and valid for access.

---

This documentation provides a high-level overview. Each endpoint may have more specific request parameters, validation rules, and response structures detailed within the respective controller actions.

*File sources:*
* [1] `config/routes.rb`
* [2] `app/controllers/api/badges_controller.rb`
* [3] `app/controllers/api/boards_controller.rb`
* [4] `app/controllers/api/button_sets_controller.rb`
* [5] `app/controllers/api/callbacks_controller.rb`
* [6] `app/controllers/api/gifts_controller.rb`
* [7] `app/controllers/api/goals_controller.rb`
* [8] `app/controllers/api/images_controller.rb`
* [9] `app/controllers/api/integrations_controller.rb`
* [10] `app/controllers/api/lessons_controller.rb`
* [11] `app/controllers/api/logs_controller.rb`
* [12] `app/controllers/api/messages_controller.rb`
* [13] `app/controllers/api/organizations_controller.rb`
* [14] `app/controllers/api/profiles_controller.rb`
* [15] `app/controllers/api/progress_controller.rb`
* [16] `app/controllers/api/purchasing_controller.rb`
* [17] `app/controllers/api/search_controller.rb`
* [18] `app/controllers/api/snapshots_controller.rb`
* [19] `app/controllers/api/sounds_controller.rb`
* [20] `app/controllers/api/tags_controller.rb`
* [21] `app/controllers/api/units_controller.rb`
* [22] `app/controllers/api/users_controller.rb`
* [23] `app/controllers/api/utterances_controller.rb`
* [24] `app/controllers/api/videos_controller.rb`
* [25] `app/controllers/api/webhooks_controller.rb`
* [26] `app/controllers/api/words_controller.rb`