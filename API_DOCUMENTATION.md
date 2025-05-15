# LingoLinq API v1 Documentation

## Overview

LingoLinq (formerly SweetSuite/CoughDrop) is an open, web-based AAC (Augmentative and Alternative Communication) application. This document provides details on the available API endpoints for integrating with LingoLinq.

## Authentication

Most API endpoints require authentication. Authentication is performed using an API token that should be included in the request headers.

`Authorization: Bearer YOUR_ACCESS_TOKEN`

Replace `YOUR_ACCESS_TOKEN` with your actual token. Some specific public-facing endpoints or actions initiated via special links (e.g., password reset, certain public log views) might have exceptions, which will be noted in their descriptions.

## Base URL

All API endpoints are prefixed with `/api/v1/`. (Example: `https://your-lingolinq-domain.com/api/v1/users/self`)

## Error Responses

When an error occurs, the API will return an appropriate HTTP status code along with a JSON response containing error details:

```json
{
  "error": "Error message",
  "errors": ["Additional error details if available"]
}
Common error codes include:

400: Bad Request - The request was invalid or missing required parameters.
401: Unauthorized - Authentication is required or failed.
403: Forbidden - You don't have permission to access the resource or perform the action.
404: Not Found - The resource was not found.
500: Internal Server Error - Something went wrong on the server.
Resources
1. Badges
Manages user badges, which can represent achievements or earned recognitions.

GET /api/v1/users/:user_id/badges
Description: Retrieves a list of badges for a specific user.
Parameters:
user_id (path, required): ID of the user.
recent (query, optional): If true, fetches recently earned/updated badges for the user and their supervisees.
goal_id (query, optional): Filter to badges for a specific goal.
highlighted (query, optional): Filter to only highlighted badges.
earned (query, optional): Filter to only earned badges.
Authentication: Required. Requires viewing rights for the user's detailed information. Supervisors see more comprehensive lists.
Response: List of badge objects.
GET /api/v1/badges/:id
Description: Retrieves a specific badge by its ID.
Authentication: Required. Requires viewing rights for the badge.
Response: Badge object.
PUT /api/v1/badges/:id
Description: Updates a specific badge.
Parameters (body):
badge (required): Badge attributes to update.
Authentication: Required. Requires editing rights for the badge.
Response: Updated badge object.
2. Boards
Manages communication boards, which are central to the application. Boards contain buttons and content for users.

GET /api/v1/boards
Description: Retrieves a list of boards.
Parameters (query):
user_id (optional): Filter by boards associated with this user (owned or shared, depending on other params).
key (optional): Find a board by its specific key.
q (optional): Search query for boards.
locale (optional): Filter by board locale.
sort (optional): Sort order (e.g., popularity, home_popularity, custom_order).
public (optional, boolean): Filter by public boards. If not specified and no user_id, defaults to public.
private (optional, boolean): Filter by private boards (requires appropriate user_id context).
starred (optional, boolean): For a given user_id, filter to their starred boards.
tag (optional, string): For a given user_id, filter by boards with a specific tag.
category (optional, string): Filter by board category.
include_shared (optional, boolean): When user_id is present, include boards shared with the user.
exclude_starred (optional, user_id string): Exclude boards starred by the specified user.
copies (optional, boolean): If false, filter to only parent boards (not copies).
root (optional, boolean): Filter for root boards.
Authentication: Varies. Public board listings might not require auth. Accessing user-specific lists or private boards requires appropriate permissions (e.g., 'view_detailed', 'model' on the user).
Response: List of board objects.
POST /api/v1/boards
Description: Creates a new board.
Parameters (body):
board (required): Object containing board attributes (e.g., key, name, grid, buttons, for_user_id, parent_board_id).
Authentication: Required. If for_user_id is specified for another user, 'edit' permission on that user is needed.
Response: Created board object.
GET /api/v1/boards/:id
Description: Retrieves a specific board by its ID or user_name/key_path. Tracks usage.
Authentication: Required. Requires 'view' permission for the board.
Response: Board object.
PUT /api/v1/boards/:id
Description: Updates a specific board or a button within a board. Can also undelete a board.
Parameters (body):
board (optional): Board attributes to update.
button (optional): Button attributes to update within the board.
Authentication: Required. Requires 'edit' permission for the board.
Response: Updated board object.
DELETE /api/v1/boards/:id
Description: Deletes a specific board.
Authentication: Required. Requires 'delete' permission for the board (or 'edit' if unstarring a sub-board).
Response: Deleted board object.
GET /api/v1/boards/:board_id/stats
Description: Retrieves usage statistics for a board.
Authentication: Required. Requires 'view' permission for the board.
Response: Board statistics object.
POST /api/v1/boards/imports
Description: Imports a board from a URL or initiates a remote upload for an OBF/OBZ file.
Parameters (body):
url (optional): URL to import from directly.
type (optional, if no url): obf or obz to initiate remote upload.
Authentication: Required.
Response: Progress object or remote upload parameters.
POST /api/v1/boards/:board_id/stars
Description: Stars a board for the API user.
Authentication: Required. Requires 'view' permission for the board.
Response: Star status.
DELETE /api/v1/boards/:board_id/stars (Maps to unstar action)
Description: Unstars a board for the API user.
Authentication: Required. Requires 'view' permission for the board.
Response: Unstar status.
POST /api/v1/boards/:board_id/download
Description: Initiates a background job to generate a downloadable version of the board.
Parameters (body): type, include, headerless, text_on_top, transparent_background, symbol_background, text_only, text_case, font.
Authentication: Required. Requires 'view' permission for the board.
Response: Progress object.
POST /api/v1/boards/:board_id/rename
Description: Renames a board by changing its key.
Parameters (body):
new_key (required): New key for the board.
old_key (required): Current key of the board.
Authentication: Required. Requires 'edit' permission for the board.
Response: Rename status.
POST /api/v1/boards/:board_id/translate
Description: Initiates a background job to translate a board and optionally other related boards.
Parameters (body): translations (object, required), source_lang (required), destination_lang (required), fallbacks (boolean, optional), board_ids_to_translate (array, optional), set_as_default (boolean, optional).
Authentication: Required. Requires 'edit' permission for the board.
Response: Progress object.
POST /api/v1/boards/:board_id/swap_images
Description: Initiates a background job to swap images on a board to a specified library.
Parameters (body): library (required), board_ids_to_convert (array, optional), include_new (boolean, optional).
Authentication: Required. Requires 'edit' permission for the board.
Response: Progress object.
POST /api/v1/boards/:board_id/privacy (Maps to update_privacy action)
Description: Initiates a background job to update the privacy settings for a board.
Parameters (body): privacy (string, required), board_ids_to_update (array, optional).
Authentication: Required. Requires 'edit' permission for the board.
Response: Progress object.
POST /api/v1/boards/:board_id/tag
Description: Tags a board for the API user.
Parameters (body): tag (string, required), remove (boolean, optional), downstream (boolean, optional).
Authentication: Required. Requires 'view' permission for the board.
Response: Tagging status.
POST /api/v1/boards/:board_id/rollback
Description: Rolls back a board to a previous version based on a date. Can also restore a deleted board.
Parameters (body): date (string, required, YYYY-MM-DD).
Authentication: Required. Requires 'edit' permission on the board or 'admin_support_actions'. For deleted boards, 'view_deleted_boards' on the user.
Response: Rollback status.
GET /api/v1/boardversions?board_id=:board_id (Also accessible via GET /api/v1/boards/:board_id/history)
Description: Retrieves the version history for a specific board.
Parameters (query): board_id (required).
Authentication: Required. Requires 'edit' on the board or 'admin_support_actions'.
Response: List of board version objects.
GET /api/v1/boards/:board_id/simple.obf
Description: Get a board in simplified Open Board Format.
Authentication: Required. Requires 'view' permission for the board.
Response: OBF file.
POST /api/v1/boards/:board_id/share_response
Description: Respond to a board share request.
Parameters (body): approve (boolean, required).
Authentication: Required.
Response: Share status.
GET /api/v1/boards/:board_id/copies
Description: Get copies of a board made by the current user.
Authentication: Required. Requires 'view' permission on the board.
Response: List of board objects.
POST /api/v1/boards/unlink (Collection action)
Description: Unlinks a board from a user in various ways (delete, unstar, unshare, untag).
Parameters (body): board_id (required), user_id (required), type (required: 'delete', 'unstar', 'unlink', 'untag'), tag (optional, if type is 'untag').
Authentication: Required. Permissions vary by type ('delete' board, 'edit' user).
Response: Removal status.
POST /api/v1/boards/:board_id/slice_locales
Description: Slices locales for a board.
Parameters (body): locales (array, required), ids_to_update (array, optional).
Authentication: Required. Requires 'edit' permission on the board.
Response: Progress object.
3. Button Sets
Manages pre-defined sets of buttons that can be applied to boards. These are often implicitly tied to specific boards.

GET /api/v1/buttonsets?user_id=:user_id
Description: Retrieves button sets (BoardDownstreamButtonSet) for a user.
Parameters (query): user_id (required).
Authentication: Required. Requires 'model' permission on the user.
Response: List of button set objects.
GET /api/v1/buttonsets/:id
Description: Retrieves a specific button set (often linked to a board, where :id is the board's global ID).
Authentication: Required. Requires 'view' permission on the associated board.
Response: Button set object.
POST /api/v1/buttonsets/:id/generate (:id is usually board ID)
Description: Generates or retrieves the URL for a button set if it exists and is up-to-date. If missing=true is passed, it can influence regeneration.
Parameters (body): missing (boolean, optional).
Authentication: Required. Requires 'view' permission on the associated board.
Response: Button set URL or progress object.
4. Callbacks
Handles callbacks from external services.

POST /api/v1/callback
Description: Processes incoming notifications from AWS SNS for services like audio/video transcoding and inbound SMS.
Headers: Expects x-amz-sns-topic-arn and x-amz-sns-message-type.
Authentication: No API token. Relies on AWS SNS message signature validation.
Response: Callback status.
5. Gifts
Manages gift codes for subscriptions or features.

GET /api/v1/gifts
Description: Retrieves all gift purchases.
Authentication: Required. Requires 'admin_support_actions'.
Response: List of gift objects.
POST /api/v1/gifts
Description: Creates a new gift purchase/code.
Parameters (body): gift (required): Object with gift attributes (e.g., licenses, total_codes, amount, expires, code, email, organization_id, gift_type).
Authentication: Required. Requires 'admin_support_actions'.
Response: Created gift object.
GET /api/v1/gifts/:id (or GET /api/v1/gifts/:id::verifier)
Description: Retrieves a specific gift purchase by its code. A verifier can be used for shorter codes if not an admin.
Authentication: Required. Requires 'view' permission on the gift or admin rights.
Response: Gift object.
DELETE /api/v1/gifts/:id
Description: Deactivates a gift purchase.
Authentication: Required. Requires 'admin_support_actions'.
Response: Deactivated gift object.
GET /api/v1/gifts/code_check?code=:code (Handled by PurchasingController)
Description: Checks the validity and details of a gift code for redemption.
Parameters (query): code (required).
Authentication: Not required by API token, but code itself is a secret.
Response: {valid: boolean, error: string, type: string, discount_percent: number, extras: boolean, supporters: boolean}.
6. Goals
Manages user goals and templates for goals.

GET /api/v1/goals
Description: Retrieves goals.
Parameters (query):
user_id (optional): Filter by user.
active (optional, boolean): Filter by active status.
template (optional, boolean): Filter for template goals (requires 'delete' on user if user_id present).
template_header (optional, boolean): Retrieves goal template headers.
global (optional, boolean): Retrieves global goal templates.
template_header_id (optional): Retrieves goals linked to a template header.
Authentication: Required if accessing user-specific goals ('supervise' on user). Public/global templates may not require user-specific auth.
Response: List of goal objects.
POST /api/v1/goals
Description: Creates a new goal.
Parameters (body): goal (required): Object containing goal attributes (e.g., user_id, name).
Authentication: Required. Requires 'set_goals' on the user. If template_header is true, 'edit' on admin organization is needed.
Response: Created goal object.
GET /api/v1/goals/:id
Description: Retrieves a specific goal.
Authentication: Required. Requires 'view' permission on the goal.
Response: Goal object.
PUT /api/v1/goals/:id
Description: Updates a goal. Limited to comments if only 'comment' permission.
Parameters (body): goal (required): Goal attributes to update.
Authentication: Required. Requires 'comment' permission ('edit' for full update).
Response: Updated goal object.
DELETE /api/v1/goals/:id
Description: Deletes a goal.
Authentication: Required. Requires 'edit' permission on the goal.
Response: Deleted goal object.
7. Images
Manages images that can be used on buttons (ButtonImage model).

POST /api/v1/images
Description: Creates a new button image. Can initiate a remote upload.
Parameters (body): image (required): Object with attributes like content_type (required), and other image details.
Authentication: Required.
Response: Created image object (may include remote upload params).
GET /api/v1/images/:id
Description: Retrieves a specific button image.
Authentication: Required. Requires 'view' permission for the image.
Response: Image object.
PUT /api/v1/images/:id
Description: Updates a button image.
Parameters (body): image (required): Image attributes to update.
Authentication: Required. Requires 'view' permission for the image (Controller indicates 'view', likely 'edit' is more appropriate for an update).
Response: Updated image object.
GET /api/v1/images/batch (Collection action)
Description: Retrieves a batch of images by their IDs.
Parameters (query): ids (comma-separated string of image IDs).
Authentication: Required.
Response: List of image objects.
GET /api/v1/images/:image_id/upload_success
Description: Callback URL for successful remote image uploads. (Not a typical callable API endpoint).
Authentication: Typically none directly; S3 or other uploader would call this.
8. Integrations
Manages user integrations with external services or features.

GET /api/v1/integrations
Description: Retrieves integrations.
Parameters (query):
user_id (optional): Filter by user.
for_button (optional, boolean): Filter for integrations usable on buttons.
Authentication: Required. If user_id is specified, requires 'supervise' permission on that user.
Response: List of integration objects.
POST /api/v1/integrations
Description: Creates or updates an integration for a user.
Parameters (body): integration (required): Object with user_id, integration_key, and other settings.
Authentication: Required. Requires 'supervise' permission on the user.
Response: Created or updated integration object.
GET /api/v1/integrations/:id
Description: Retrieves a specific integration.
Authentication: Required. Requires 'view' permission on the integration.
Response: Integration object.
PUT /api/v1/integrations/:id
Description: Updates an integration.
Parameters (body): integration (required): Integration attributes to update.
Authentication: Required. Requires 'edit' permission on the integration.
Response: Updated integration object.
DELETE /api/v1/integrations/:id
Description: Deletes an integration.
Authentication: Required. Requires 'delete' permission on the integration.
Response: Deleted integration object.
GET /api/v1/domain_settings
Description: Retrieves domain-specific override settings for integrations.
Authentication: Not typically required by API token; based on domain.
Response: Domain settings object.
POST /api/v1/focus/usage
Description: Tracks the usage of a "focus" item (e.g., from OpenAAC workshop).
Parameters (body): focus_id (required).
Authentication: Required.
Response: {accepted: true}.
9. Lessons
Manages educational lessons and assignments.

GET /api/v1/lessons
Description: Retrieves lessons.
Parameters (query):
user_id (optional): Filter by user.
organization_id (optional): Filter by organization.
organization_unit_id (optional): Filter by unit.
active (optional, boolean): Filter by active lessons.
concluded (optional, boolean): Filter by concluded lessons.
history_check (optional, boolean): Performs a history check.
Authentication: Required for user/org/unit specific lists ('supervise' for user, 'edit' for org/unit). Public lessons may be accessible without auth.
Response: List of lesson objects.
POST /api/v1/lessons
Description: Creates a new lesson and can assign it.
Parameters (body): lesson (required): Object with attributes like name, organization_id (or user_id, organization_unit_id for initial assignment), target_types.
Authentication: Required. Requires 'edit' (org/unit) or 'supervise' (user) on the initial target.
Response: Created lesson object.
GET /api/v1/lessons/:id (where :id can be lesson_id::lesson_code::user_token)
Description: Retrieves a specific lesson.
Authentication: Required ('view' permission) or valid lesson_code & user_token.
Response: Lesson object.
PUT /api/v1/lessons/:id
Description: Updates a lesson.
Parameters (body): lesson (required): Lesson attributes to update.
Authentication: Required. Requires 'edit' permission on the lesson.
Response: Updated lesson object.
DELETE /api/v1/lessons/:lesson_id
Description: Deletes a lesson.
Authentication: Required. Requires 'delete' permission on the lesson.
Response: Deleted lesson object.
POST /api/v1/lessons/:lesson_id/assign
Description: Assigns a lesson to a target.
Parameters (body): user_id OR organization_id OR organization_unit_id (required).
Authentication: Required. 'view' on lesson, and 'supervise' (user) or 'edit' (org/unit) on target.
Response: Assignment status.
POST /api/v1/lessons/:lesson_id/unassign
Description: Unassigns a lesson from a target.
Parameters (body): user_id OR organization_id OR organization_unit_id (required).
Authentication: Required. 'view' on lesson, and 'supervise' (user) or 'edit' (org/unit) on target.
Response: Unassignment status.
POST /api/v1/lessons/:lesson_id/complete (:lesson_id here is lesson_id_val::lesson_code::user_token)
Description: Marks a lesson as complete for a user.
Parameters (body): rating (integer, optional), duration (integer, optional).
Authentication: Valid lesson code and user token required (no API token).
Response: Completion status, updated lesson object.
GET /api/v1/lessons/:lesson_id/recent
Description: (Controller action exists but no route seems to point here directly as a primary action. May be used internally or needs route clarification).
Authentication: Required.
10. Logs
Manages user activity logs and sessions.

GET /api/v1/users/:user_id/logs
Description: Retrieves logs for a user.
Parameters (query):
user_id (path, required).
supervisees (optional, boolean): Include logs of supervisees.
type (optional, string): Filter by log type (e.g., 'session', 'note', 'assessment', 'journal'). Default includes session, note, assessment, eval, profile.
highlighted (optional, boolean): Filter by highlighted logs.
goal_id (optional): Filter by goal ID.
location_id (optional): Filter by location ID.
device_id (optional): Filter by device ID.
start (optional, date string): Start date for logs.
end (optional, date string): End date for logs.
Authentication: Required. Requires 'supervise' on the user. Subject to logging privacy settings and codes (X-Logging-Code-For-{USER_ID} header).
Response: List of log objects.
POST /api/v1/logs (The route is POST /api/v1/logs and user_id is typically in the payload or defaults to API user)
Description: Creates a new log session or entry.
Parameters (body): log (required): Log attributes, can include user_id. If user_id is for another user, 'model' permission is needed on that user.
Authentication: Required.
Response: Created log object.
GET /api/v1/logs/:id
Description: Retrieves a specific log session.
Authentication: Required. Requires 'supervise' on the log's user, subject to logging privacy and codes.
Response: Log object.
PUT /api/v1/logs/:id
Description: Updates a log session.
Parameters (body): log (required): Log attributes to update.
Authentication: Required. Requires 'supervise' on the log's user, subject to logging privacy and codes.
Response: Updated log object.
POST /api/v1/logs/import (Collection action)
Description: Imports logs for a user from a URL/content or initiates a remote upload.
Parameters (body/query): user_id (required), url (optional) or content (optional), type (optional: obl, lam). If no url/content, initiates remote upload.
Authentication: Required. Requires 'supervise' on the user.
Response: Progress object or remote upload parameters.
GET /api/v1/logs/:log_id/lam
Description: Retrieves log data in LAM format if nonce matches.
Parameters (query): nonce (required).
Authentication: Not required by API token if nonce is valid.
Response: LAM data (plain text).
POST /api/v1/logs/obl (Collection action, distinct from GET in MD_Doc)
Description: Initiates an OBL export for a specific log or all logs for a user.
Parameters (body/query): log_id (optional) or user_id (optional), anonymized (boolean, optional for user export).
Authentication: Required. Requires 'supervise' on the user, subject to logging privacy and codes.
Response: Progress object.
POST /api/v1/logs/code_check (Collection action)
Description: Checks if a provided logging code is valid for a user.
Parameters (body/query): user_id (required), code (required).
Authentication: Required. Requires 'supervise' on the user.
Response: {valid: boolean}.
GET /api/v1/logs/trends (Collection action)
Description: Retrieves global statistic trends. Cached.
Authentication: Not required by API token. Admin users see more data.
Response: Trends data object or progress object if generating.
GET /api/v1/logs/trends_slice (Collection action)
Description: Retrieves trends for a slice of users, authenticated by an integration key/secret.
Parameters (query): integration_id (required), integration_secret (required), user_ids (required, comma-separated).
Authentication: Not required by API token; uses integration credentials.
Response: Trends slice data or progress object.
GET /api/v1/logs/anonymous_logs (Collection action)
Description: Retrieves a URL for downloading anonymous log data. Cached.
Authentication: Not required by API token.
Response: URL object or progress object if generating.
11. Messages (Contact/Support)
Handles creation of contact messages (support tickets).

POST /api/v1/messages
Description: Creates a new contact message.
Parameters (body): message (required): Message attributes (subject, body, email, etc.).
Authentication: API token required, OR if ENV['ALLOW_UNAUTHENTICATED_TICKETS'] is true.
Response: {received: true, id: message_global_id}.
12. Organizations
Manages organizations, their users, settings, and related data.

GET /api/v1/organizations
Description: Retrieves a list of all organizations.
Authentication: Required. Requires 'edit' permission on the admin organization.
Response: List of organization objects.
POST /api/v1/organizations
Description: Creates a new organization.
Parameters (body): organization (required): Organization attributes.
Authentication: Required. Requires 'manage' permission on the admin organization.
Response: Created organization object.
GET /api/v1/organizations/:id
Description: Retrieves a specific organization.
Authentication: Required. Requires 'view' permission on the organization.
Response: Organization object.
PUT /api/v1/organizations/:id
Description: Updates an organization. Specific fields require higher privileges.
Parameters (body): organization (required): Organization attributes to update.
Authentication: Required. Requires 'edit' permission. Specific attributes require 'update_licenses' or 'delete'.
Response: Updated organization object.
DELETE /api/v1/organizations/:id
Description: Deletes an organization.
Authentication: Required. Requires 'delete' permission on the organization.
Response: Deleted organization object.
GET /api/v1/organizations/:organization_id/users
Parameters (query): recent (optional, boolean): Sort by recent.
Authentication: Required. Requires 'edit' permission on the organization.
Response: List of user objects.
GET /api/v1/organizations/:organization_id/managers
Authentication: Required. Requires 'edit' permission on the organization.
Response: List of user objects (managers).
GET /api/v1/organizations/:organization_id/supervisors
Authentication: Required. Requires 'edit' permission on the organization.
Response: List of user objects (supervisors).
GET /api/v1/organizations/:organization_id/evals
Description: List evaluators in an organization (users with eval role/permissions).
Authentication: Required. Requires 'edit' permission on the organization.
Response: List of user objects.
GET /api/v1/organizations/:organization_id/stats
Authentication: Required. Requires 'edit' permission on the organization.
Response: Organization statistics object.
GET /api/v1/organizations/:organization_id/logs
Authentication: Required. Requires 'manage' permission on the organization.
Response: List of log objects associated with the organization.
POST /api/v1/organizations/:organization_id/start_code
Description: Creates or deletes a start code for an organization.
Parameters (body): delete (boolean, optional), code (string, optional for deletion), overrides (object, optional for creation).
Authentication: Required. Requires 'edit' permission on the organization.
Response: Start code object or deletion status.
GET /api/v1/start_code (Global, not under specific org ID for lookup)
Description: Looks up an activation/start code.
Parameters (query): code (required), v (verifier, optional but sometimes needed).
Authentication: Valid verifier, or 'edit' permission on the target by the API user.
Response: Start code details.
POST /api/v1/organizations/:organization_id/status/:user_id
Description: Sets the status of a user within an organization.
Parameters (body): status (required, object with state and optional note).
Authentication: Required. Supervisor/manager of the org or 'manage' on org, and 'supervise' on the user.
Response: Status update confirmation.
GET /api/v1/organizations/:organization_id/extras
Description: List extra users (e.g., supporters with extra features) in an organization.
Authentication: Required. Requires 'edit' permission on the organization.
Response: List of user objects.
GET /api/v1/organizations/:organization_id/admin_reports
Parameters (query): report (string, required): Type of report.
Authentication: Required. Requires 'edit' permission on the organization. Non-admin orgs have limited report types.
Response: Report data.
GET /api/v1/organizations/:organization_id/blocked_emails
Authentication: Required. Admin organization manager only.
Response: List of blocked emails.
GET /api/v1/organizations/:organization_id/blocked_cells
Authentication: Required. Admin organization manager only.
Response: List of blocked cell numbers.
POST /api/v1/organizations/:organization_id/alias
Description: Create an external authentication (SAML) alias for a user in an organization.
Parameters (body): user_id (required), alias (required).
Authentication: Required. Requires 'edit' on the organization. Org must be SAML configured.
Response: Alias creation status.
POST /api/v1/organizations/:organization_id/extra_action
Parameters (body): extra_action (required), other params vary by action.
Authentication: Required. Admin organization manager only.
Response: Action status.
13. Profiles (Templates & User Profile Logs)
Manages user profile templates and instances (profile completions are often stored as logs).

GET /api/v1/profiles?user_id=:user_id
Description: Retrieves profile templates available to a user (static, global, org-specific).
Parameters (query): user_id (required).
Authentication: Required. Requires 'supervise' permission on the user.
Response: List of profile template objects.
GET /api/v1/profiles/:id
Description: Retrieves a specific profile template by its code or static ID.
Authentication: Required. Requires 'view' permission on the profile template.
Response: Profile template object.
GET /api/v1/profiles/latest?user_id=:user_id (Collection action)
Description: Retrieves the latest profile sessions (logs of type 'profile') for a user.
Parameters (query): user_id (required), profile_id (optional), include_suggestions (boolean, optional).
Authentication: Required. Requires 'supervise' permission on the user.
Response: List of profile session objects (or templates if suggested).
14. Progress
Tracks the status of background jobs.

GET /api/v1/progress/:id
Description: Retrieves the status of a specific background job.
Authentication: Required. Requires 'view' permission on the progress item (usually linked to initiating user).
Response: Progress object.
15. Purchasing
Handles purchasing events and gift code management related to payments.

POST /api/v1/purchasing_event
Description: Handles subscription events from a payment provider (e.g., Stripe webhook).
Authentication: Not by API token; typically webhook secret/signature from provider.
Response: Event status.
POST /api/v1/purchase_gift
Description: Processes a gift purchase using a payment token.
Parameters (body): token (payment token object, required), type (required), code (gift code, optional), email (optional), extras (boolean, optional), supporters (integer, optional), donate (boolean, optional).
Authentication: Required (API user initiating the purchase).
Response: Progress object. (Note: GET /api/v1/gifts/code_check is covered under "Gifts" but handled by PurchasingController).
16. Search
Provides various search functionalities.

GET /api/v1/search/symbols
Description: Searches for symbols via OpenSymbols.org and premium libraries.
Parameters (query): q (required), locale (optional), safe (boolean, optional), user_name (optional, for premium repo context).
Authentication: Required. Premium searches require user subscription/permissions.
Response: List of symbol objects.
GET /api/v1/search/protected_symbols
Description: Searches for symbols in specifically protected libraries.
Parameters (query): q (required), library (required), user_name (optional, for user context).
Authentication: Required. User must have access to the library.
Response: List of symbol objects.
GET /api/v1/search/external_resources
Description: Searches for external resources (e.g., YouTube, Vimeo).
Parameters (query): q (required), source (required), user_name (optional, for user context).
Authentication: Required.
Response: List of resource objects.
GET /api/v1/search/proxy
Description: Proxies a request to an external URL, returning content base64 encoded.
Parameters (query): url (required).
Authentication: Required.
Response: Proxied content object ({content_type: string, data: string}).
GET /api/v1/search/parts_of_speech
Description: Retrieves parts of speech and linguistic data for a word.
Parameters (query): q (word, required), suggestions (boolean, optional).
Authentication: Required.
Response: Word data object.
GET /api/v1/search/apps
Description: Searches for applications.
Parameters (query): q (required), os (optional).
Authentication: Required.
Response: List of app objects.
GET /api/v1/search/audio
Description: Synthesizes speech using a TTS engine.
Parameters (query): text (required), locale (optional, default 'en'), voice_id (optional), mp3 (optional, boolean for Google TTS).
Authentication: Not required by API token.
Response: Audio data (e.g., WAV or MP3 file).
GET /api/v1/search/focuses (Maps to search#focuses)
Description: Searches for "focus" items from workshop.openaac.org.
Parameters (query): q (optional), locale (optional, default 'en'), category (optional), type (optional), sort (optional).
Authentication: Not required by API token.
Response: List of focus words/items.
17. Snapshots
Manages snapshots of user log data.

GET /api/v1/users/:user_id/snapshots
Description: Retrieves snapshots for a user.
Authentication: Required. Requires 'supervise' permission on the user.
Response: List of snapshot objects.
POST /api/v1/snapshots
Description: Creates a new log snapshot for a user.
Parameters (body): snapshot (required): Object with user_id and snapshot details.
Authentication: Required. Requires 'edit' permission on the user.
Response: Created snapshot object.
GET /api/v1/snapshots/:id
Description: Retrieves a specific snapshot.
Authentication: Required. Requires 'view' permission on the snapshot (via user).
Response: Snapshot object.
PUT /api/v1/snapshots/:id
Description: Updates a snapshot.
Parameters (body): snapshot (required): Snapshot attributes to update.
Authentication: Required. Requires 'edit' permission on the snapshot.
Response: Updated snapshot object.
DELETE /api/v1/snapshots/:id
Description: Deletes a snapshot.
Authentication: Required. Requires 'delete' permission on the snapshot.
Response: Deleted snapshot object.
18. Sounds
Manages sound recordings that can be attached to buttons.

GET /api/v1/users/:user_id/sounds
Description: Retrieves sounds uploaded by a specific user.
Authentication: Required. Requires 'supervise' permission on the user.
Response: List of sound objects.
POST /api/v1/sounds
Description: Creates a new button sound. Can be for API user or another user.
Parameters (body): sound (required): Sound attributes, can include user_id.
Authentication: Required. If for another user, requires 'supervise' on that user.
Response: Created sound object (may include remote upload params).
POST /api/v1/sounds/imports (Collection action)
Description: Imports sounds from a URL or initiates remote upload of a ZIP file.
Parameters (body/query): user_id (implied API user unless specified in payload), url (optional). If no url, initiates upload.
Authentication: Required.
Response: Progress object or remote upload parameters.
GET /api/v1/sounds/:id
Description: Retrieves a specific button sound.
Authentication: Required. Requires 'view' permission for the sound.
Response: Sound object.
PUT /api/v1/sounds/:id
Description: Updates a button sound.
Parameters (body): sound (required): Sound attributes to update.
Authentication: Required. Requires 'edit' permission for the sound.
Response: Updated sound object.
DELETE /api/v1/sounds/:id
Description: Deletes a button sound.
Authentication: Required. Requires 'edit' permission for the sound.
Response: Deleted sound object.
GET /api/v1/sounds/:sound_id/upload_success
Description: Callback URL for successful remote sound uploads. (Not a typical callable API).
Authentication: None directly.
19. Tags (NFC)
Manages NFC tags and their associated content.

GET /api/v1/tags
Description: Retrieves NFC tags for the API user or a specified user that have content.
Parameters (query): user_id (optional, defaults to API user).
Authentication: Required. If user_id specified, requires 'model' permission on that user.
Response: List of tag objects.
POST /api/v1/tags
Description: Creates a new NFC tag entry for the API user.
Parameters (body): tag (required): Tag attributes.
Authentication: Required. (Controller implies 'supervise' on self).
Response: Created tag object.
GET /api/v1/tags/:id
Description: Retrieves an NFC tag by its global ID or physical tag ID.
Authentication: Required. If tag is not public, requires 'model' on tag's user.
Response: Tag object.
PUT /api/v1/tags/:id
Description: Updates an NFC tag.
Parameters (body): tag (required): Tag attributes to update.
Authentication: Required. Requires 'supervise' on tag's user.
Response: Updated tag object.
DELETE /api/v1/tags/:id
Description: Deletes an NFC tag.
Authentication: Required. Requires 'supervise' on tag's user.
Response: Deleted tag object.
20. Units (Organization Units / Rooms)
Manages organizational units, often referred to as rooms.

GET /api/v1/organizations/:organization_id/units
Description: Retrieves units for an organization.
Authentication: Required. Requires 'edit' permission on the organization.
Response: List of unit objects.
POST /api/v1/units
Description: Creates a new organizational unit.
Parameters (body): unit (required): Object with organization_id and unit details.
Authentication: Required. Requires 'edit' permission on the parent organization.
Response: Created unit object.
GET /api/v1/units/:id
Description: Retrieves a specific organizational unit.
Authentication: Required. Requires 'view' permission on the unit.
Response: Unit object.
PUT /api/v1/units/:id
Description: Updates an organizational unit.
Parameters (body): unit (required): Unit attributes to update.
Authentication: Required. Requires 'edit' permission on the unit.
Response: Updated unit object.
DELETE /api/v1/units/:id
Description: Deletes an organizational unit.
Authentication: Required. Requires 'delete' permission on the unit.
Response: Deleted unit object.
GET /api/v1/units/:unit_id/stats
Description: Retrieves usage statistics for a unit.
Authentication: Required. Requires 'view_stats' permission on the unit.
Response: Unit statistics object.
GET /api/v1/units/:unit_id/log_stats
Description: Retrieves aggregated log statistics for a unit.
Authentication: Required. Requires 'view_stats' permission on the unit.
Response: Log statistics object.
GET /api/v1/units/:unit_id/logs
Description: Retrieves session logs for communicator users within a unit.
Authentication: Required. Requires 'view_stats' permission on the unit.
Response: List of log objects.
POST /api/v1/units/:unit_id/note
Description: Sends a message (note) to users within a unit.
Parameters (body): note (text, required), target (optional: 'communicators', 'supervisors', 'all'), video_id (optional), include_footer (boolean, optional), notify_user (boolean, optional), notify_exclude_ids (array, optional).
Authentication: Required. Requires 'view_stats' permission on the unit.
Response: {targets: count}.
21. Users
Manages user accounts, settings, and related actions.

GET /api/v1/users
Description: Searches for users.
Parameters (query): q (required), org_id (optional).
Authentication: Required. Requires 'admin_support_actions', or 'edit' on org_id if provided.
Response: List of user objects.
POST /api/v1/users
Description: Creates a new user (registers). Sends confirmation email.
Parameters (body): user (required): User attributes (e.g., user_name, email, password, start_code).
Authentication: Not required by API token for this specific action.
Response: Created user object, includes meta with token for new user.
GET /api/v1/users/:id
Description: Retrieves a specific user's details.
Authentication: Required ('view_existence'), or if confirmation code matches registration code.
Response: User object.
PUT /api/v1/users/:id
Description: Updates a user's details. Password changes need reset_token or admin rights.
Parameters (body): user (required): User attributes to update. reset_token (optional).
Authentication: Required ('edit'), or valid reset_token, or 'support_actions' for admin password reset, or 'manage_supervision' for limited updates.
Response: Updated user object.
POST /api/v1/users/:user_id/confirm_registration
Description: Confirms user registration or resends confirmation.
Parameters (body/query): code (optional), resend (boolean, optional).
Authentication: Not required by API token.
Response: Confirmation status.
POST /api/v1/forgot_password
Description: Initiates password reset process.
Parameters (body): key (username or email, required).
Authentication: Not required by API token.
Response: Reset status.
POST /api/v1/users/:user_id/password_reset
Description: Validates password reset code.
Parameters (body/query): code (required).
Authentication: Not required by API token.
Response: {valid: boolean, reset_token: string}.
GET /api/v1/users/:user_id/stats/daily
Authentication: Required. Requires 'supervise' on the user.
Response: Daily statistics object.
GET /api/v1/users/:user_id/stats/hourly
Authentication: Required. Requires 'supervise' on the user.
Response: Hourly statistics object.
GET /api/v1/users/:user_id/alerts
Authentication: Required. Requires 'supervise' on the user.
Response: List of alert objects.
POST /api/v1/users/:user_id/subscription
Description: Manages user subscriptions (redeem codes, admin overrides, process payments).
Parameters (body): type (required: e.g., 'gift_code', 'eval'), token (payment or gift code, optional), code (gift code, optional), confirmation (for initial registration).
Authentication: Required for most types ('edit' on user, 'admin_support_actions' for overrides). Registration confirmation code for initial.
Response: Progress object.
DELETE /api/v1/users/:user_id/subscription
Description: Unsubscribes a user.
Parameters (body): reason (optional).
Authentication: Required. Requires 'edit' on the user.
Response: Progress object.
POST /api/v1/users/:user_id/verify_receipt
Description: Verifies a mobile app purchase receipt.
Parameters (body): receipt_data (required).
Authentication: Required. Requires 'edit' on the user.
Response: Progress object.
POST /api/v1/users/:user_id/flush/logs (Maps to flush_logs)
Description: Initiates deletion of all logs for a user. Requires confirmation.
Parameters (body): user_name (required), confirm_user_id (required).
Authentication: Required. Requires 'delete' on the user.
Response: Progress object or error.
POST /api/v1/users/:user_id/flush/user
Description: Schedules a user account for deletion.
Parameters (body): user_name (required), confirm_user_id (required).
Authentication: Required. Requires 'delete' on the user.
Response: {flushed: 'pending'} or error.
DELETE /api/v1/users/:user_id/devices/:device_id (Maps to hide_device)
Description: Hides a device from the user's device list.
Authentication: Required. Requires 'delete' on the user.
Response: Device object.
PUT /api/v1/users/:user_id/devices/:device_id (Maps to rename_device)
Description: Renames a device.
Parameters (body): device (required, object with name).
Authentication: Required. Requires 'edit' on the user.
Response: Device object.
GET /api/v1/users/:user_id/supervisors
Authentication: Required. Requires 'supervise' on the user.
Response: List of user objects (supervisors).
GET /api/v1/users/:user_id/supervisees
Authentication: Required. Requires 'supervise' on the user (to see their own supervisees).
Response: List of user objects (supervisees).
POST /api/v1/users/:user_id/claim_voice
Parameters (body): voice_id (required), system (required), voice_url (optional), language_url (optional), binary_url (optional).
Authentication: Required. Requires 'edit' on the user.
Response: Voice claim status, potential download URLs.
POST /api/v1/users/:user_id/start_code
Description: Generates or deletes a start code for a user (if they are a supporter).
Parameters (body): delete (boolean, optional), code (string, optional for deletion), overrides (object, optional for creation).
Authentication: Required. Requires 'edit' on the user, and user must be supporter role.
Response: Start code object or deletion status.
POST /api/v1/users/:user_id/activate_button
Description: Activates an integration button.
Parameters (body): board_id (required), button_id (required), associated_user_id (optional).
Authentication: Required for users other than 'nobody'. User needs 'model' permission. Board and button must be viewable.
Response: Progress object.
POST /api/v1/users/:user_id/rename
Parameters (body): new_key (required), old_key (required, current username).
Authentication: Required. Requires 'support_actions' on the user.
Response: Rename status.
GET /api/v1/users/:user_id/sync_stamp
Authentication: Required. User must be self.
Response: {sync_stamp: iso8601_string, badges_updated_at: iso8601_string}.
POST /api/v1/users/:user_id/translate
Parameters (body): words (array of strings, required), source_lang (required), destination_lang (required).
Authentication: Required. Requires 'delete' on the user (unusual permission, might be an oversight).
Response: Translations object.
GET /api/v1/users/:user_id/board_revisions
Authentication: Required. Requires 'model' on the user.
Response: Object mapping board IDs/keys to revision strings.
GET /api/v1/users/:user_id/boards
Parameters (query): ids (comma-separated string of board IDs, required).
Authentication: Required. Requires 'model' on the user.
Response: List of board objects.
GET /api/v1/users/:user_id/places
Parameters (query): latitude (required), longitude (required).
Authentication: Required. Requires 'model' on the user.
Response: List of place objects.
GET /api/v1/users/:user_id/ws_settings
Authentication: Required. Requires 'supervise' on the user.
Response: Websocket settings object for the user, including verifier.
GET /api/v1/users/ws_lookup (Collection action)
Parameters (query): user_id (obfuscated websocket user ID, required).
Authentication: Required. API user must have 'supervise' permission on the looked-up user.
Response: User details for websocket connection.
POST /api/v1/users/:user_id/ws_encrypt
Parameters (body): text (required).
Authentication: Required. Requires 'supervise' on the user.
Response: {encoded: string, user_id: string}.
POST /api/v1/users/:user_id/ws_decrypt
Parameters (body): text (encrypted string, required).
Authentication: Required. Requires 'supervise' on the user.
Response: {decoded: string, user_id: string} or error.
GET /api/v1/users/:user_id/daily_use
Authentication: Required. Requires 'admin_support_actions'.
Response: Daily use data log object.
GET /api/v1/users/:user_id/core_lists
Parameters (query): user_id (can be 'none' for defaults).
Authentication: Required if user_id is not 'none'; requires 'model' on the user.
Response: Core and fringe word lists.
PUT /api/v1/users/:user_id/core_list (Maps to update_core_list)
Parameters (body): id (list ID, required), words (array or string, required).
Authentication: Required. Requires 'edit' on the user.
Response: Update status.
GET /api/v1/message_bank_suggestions (No user_id in path)
Authentication: Required (Controller implies this).
Response: List of message bank suggestions.
GET /api/v1/users/:user_id/protected_image/:library/:image_id
Parameters (query): user_token (required).
Authentication: Not by API token; uses user_token for image access verification.
Response: Image data.
GET /api/v1/users/:user_id/word_map
Authentication: Required. Requires 'view_word_map' on the user.
Response: Word map object.
GET /api/v1/users/:user_id/word_activities
Authentication: Required. Requires 'model' on the user.
Response: Activities object or progress object if generating.
POST /api/v1/users/:user_id/evals/transfer
Parameters (body): user_name (target username, required), password (target user password, required).
Authentication: Required. Requires 'edit' on the source eval user.
Response: Progress object.
POST /api/v1/users/:user_id/evals/reset
Parameters (body): email (optional), password (optional), home_board_key (optional), symbol_library (optional), expires (optional).
Authentication: Required. Requires 'edit' on the user. Restrictions apply if user has supervisors or is org-managed.
Response: Progress object.
POST /api/v1/users/:user_id/2fa (Maps to update_2fa)
Parameters (body): action_2fa (required: 'enable', 'disable', 'reset', 'confirm'), code_2fa (optional for confirm).
Authentication: Required. Requires 'edit' on the user.
Response: 2FA status, may include OTP URI.
GET /api/v1/users/:user_id/external_nonce/:nonce_id
Parameters (query): ref_type (optional), ref_id (optional).
Authentication: Required. If ref_type is log_session, requires 'supervise' on log's user.
Response: Nonce encryption result.
POST /api/v1/users/:user_id/replace_board
Description: Replaces a board and its links for a user.
Parameters (body): old_board_id, new_board_id, old_default_locale, new_default_locale, ids_to_copy, copy_prefix, update_inline, new_owner, disconnect, make_public. (Many optional).
Authentication: Required. Requires 'edit' on the user, 'view' on boards.
Response: Progress object.
POST /api/v1/users/:user_id/copy_board_links
Description: Copies links from an old board to a new board for a user.
Parameters (body): old_board_id, new_board_id, old_default_locale, new_default_locale, ids_to_copy, copy_prefix, make_public, new_owner, disconnect, swap_library. (Many optional).
Authentication: Required. Requires 'edit' on the user, 'view' on boards.
Response: Progress object.
GET /api/v1/users/:user_id/history (Maps to userversions)
Authentication: Required. Requires 'admin_support_actions'.
Response: List of user version objects.
GET /api/v1/userversions (Global, alternative to user-specific history)
Parameters (query): user_id (required).
Authentication: Required. Requires 'admin_support_actions'.
Response: List of user version objects for the specified user.
GET /api/v1/users/:user_id/valet_credentials
Description: Get temporary credentials for modeling a user.
Authentication: Required. Requires 'delete' permission on the user. User must have valet password set up.
Response: Temporary credentials object.
22. Utterances
Manages user utterances (spoken phrases or messages).

POST /api/v1/utterances
Description: Creates a new utterance.
Parameters (body): utterance (required): Utterance attributes, can include user_id.
Authentication: Required. If for another user, requires 'model' permission on that user.
Response: Created utterance object.
GET /api/v1/utterances/:id (where :id can be utterance_id::reply_code)
Description: Retrieves a specific utterance.
Authentication: Required ('view' permission) or valid reply_code.
Response: Utterance object.
PUT /api/v1/utterances/:id
Description: Updates an utterance.
Parameters (body): utterance (required): Utterance attributes to update.
Authentication: Required. Requires 'edit' permission on the utterance.
Response: Updated utterance object.
POST /api/v1/utterances/:utterance_id/share
Description: Shares an utterance.
Parameters (body): user_id (target user, optional), contact_type & contact_value (optional), sharer_id (optional).
Authentication: Required. Requires 'edit' on the utterance. If sharer_id is different, 'model' on that sharer. Premium access may be required.
Response: Share status.
POST /api/v1/utterances/:utterance_id/reply (:utterance_id here is utterance_id_val::reply_code)
Description: Sends a reply to an utterance via a reply code.
Parameters (body): message (text, required).
Authentication: Valid reply code required (no API token).
Response: Reply status.
23. Videos
Manages user-uploaded videos.

POST /api/v1/videos
Description: Creates a new user video. Can initiate remote upload.
Parameters (body): video (required): Video attributes.
Authentication: Required.
Response: Created video object (may include remote upload params).
GET /api/v1/videos/:id
Description: Retrieves a specific user video.
Authentication: Required. Requires 'view' permission for the video.
Response: Video object.
PUT /api/v1/videos/:id
Description: Updates a user video.
Parameters (body): video (required): Video attributes to update.
Authentication: Required. Requires 'edit' permission for the video.
Response: Updated video object.
GET /api/v1/videos/:video_id/upload_success
Description: Callback URL for successful remote video uploads. (Not a typical callable API).
Authentication: None directly.
24. Webhooks
Manages webhooks for user event notifications.

GET /api/v1/users/:user_id/webhooks
Description: Retrieves webhooks for a user.
Authentication: Required. Requires 'supervise' permission on the user.
Response: List of webhook objects.
POST /api/v1/webhooks
Description: Creates a new webhook.
Parameters (body): webhook (required): Object with user_id and webhook details.
Authentication: Required. Requires 'supervise' on the user for whom webhook is created.
Response: Created webhook object.
PUT /api/v1/webhooks/:id
Description: Updates a webhook.
Parameters (body): webhook (required): Webhook attributes to update.
Authentication: Required. Requires 'edit' permission on the webhook.
Response: Updated webhook object.
DELETE /api/v1/webhooks/:id
Description: Deletes a webhook.
Authentication: Required. Requires 'delete' permission on the webhook.
Response: Deleted webhook object.
POST /api/v1/webhooks/:webhook_id/test
Authentication: Required. Requires 'edit' permission on the webhook.
Response: Progress object.
25. Words (Word Data & Language Rules)
Manages linguistic data for words and language-specific rules.

GET /api/v1/words
Description: Retrieves word data for a locale, primarily for admin review.
Parameters (query): locale (required), word (optional, specific word to find).
Authentication: Required. Requires 'admin_support_actions'.
Response: List of word data objects.
PUT /api/v1/words/:id
Description: Updates word data (e.g., part of speech, definitions).
Parameters (body): word (required): Word attributes to update, or skip (boolean).
Authentication: Required. Requires 'admin_support_actions'.
Response: Updated word data object.
GET /api/v1/lang/:locale
Description: Retrieves language-specific rules (inflections, contractions) for a locale.
Authentication: Not required by API token.
Response: Language rules object.
GET /api/v1/users/:user_id/words/reachable_core (Maps to words#reachable_core)
Description: Retrieves a list of "reachable core" words for a user.
Parameters (query): utterance_id (optional, utterance_id::reply_code for access via utterance).
Authentication: Required ('supervise' on user), OR if utterance_id is provided and valid for access.
Response: {words: ["word1", "word2"]}.
Data Structures
(Retaining this section from your api-documentation.md as it's very useful. These should be verified against the actual JSON responses from the API for accuracy.)

Badge
JSON

{
  "id": "string",
  "name": "string",
  "image_url": "string",
  "sound_url": "string",
  "level": "number",
  "progress": "number",
  "earned": "boolean",
  "goal_id": "string"
}
Board
JSON

{
  "id": "string",
  "key": "string",
  "name": "string",
  "description": "string",
  "image_url": "string",
  "user_id": "string",
  "public": "boolean",
  "created_at": "date",
  "updated_at": "date",
  "parent_board_id": "string",
  "word_suggestions": "boolean",
  "current_revision": "string",
  "locale": "string",
  "locales": ["string"],
  "popularity": "number",
  "home_popularity": "number",
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean"
  },
  "grid": {
    "rows": "number",
    "columns": "number",
    "order": [["number"]]
  },
  "buttons": [
    {
      "id": "string",
      "label": "string",
      "vocalization": "string",
      "image_id": "string",
      "sound_id": "string",
      "background_color": "string",
      "border_color": "string",
      "part_of_speech": "string",
      "link_disabled": "boolean",
      "board_id": "string",
      "integration": {
        "user_integration_id": "string",
        "action_type": "string",
        "action_text": "string"
      }
    }
  ]
}
ButtonSet
JSON

{
  "id": "string",
  "board_id": "string",
  "board_global_id": "string",
  "board_key": "string",
  "user_id": "string",
  "data": "object",
  "url": "string"
}
Gift
JSON

{
  "id": "string",
  "code": "string",
  "gift_type": "string",
  "amount": "number",
  "licenses": "number",
  "expires_at": "date",
  "memo": "string",
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean"
  }
}
Goal
JSON

{
  "id": "string",
  "name": "string",
  "summary": "string",
  "status": "string",
  "started_at": "date",
  "ended_at": "date",
  "active": "boolean",
  "user_id": "string",
  "template": "boolean",
  "global": "boolean",
  "template_header": "boolean",
  "badges": ["Badge"],
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean",
    "comment": "boolean"
  }
}
Image (ButtonImage)
JSON

{
  "id": "string",
  "image_url": "string",
  "thumbnail_url": "string",
  "content_type": "string",
  "user_id": "string",
  "license": "string",
  "author": "string",
  "source_url": "string",
  "protected": "boolean",
  "protected_source": "string",
  "permissions": {
    "view": "boolean",
    "edit": "boolean"
  }
}
Integration
JSON

{
  "id": "string",
  "name": "string",
  "user_id": "string",
  "integration_key": "string",
  "template": "boolean",
  "webhook_url": "string",
  "for_button": "boolean",
  "render_url": "string",
  "settings": "object",
  "permissions": {
      "view": "boolean",
      "edit": "boolean",
      "delete": "boolean"
  }
}
Lesson
JSON

{
  "id": "string",
  "name": "string",
  "summary": "string",
  "duration": "number",
  "public": "boolean",
  "user_id": "string",
  "organization_id": "string",
  "organization_unit_id": "string",
  "content": "object",
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean"
  }
}
Log (LogSession)
JSON

{
  "id": "string",
  "user_id": "string",
  "author_id": "string",
  "log_type": "string",
  "started_at": "date",
  "ended_at": "date",
  "duration": "number",
  "summary": "string",
  "notes": "string",
  "goal_id": "string",
  "highlighted": "boolean",
  "data": "object",
  "permissions": {
      "view": "boolean"
  }
}
Organization
JSON

{
  "id": "string",
  "name": "string",
  "admin": "boolean",
  "parent_org_id": "string",
  "contact_name": "string",
  "contact_email": "string",
  "allotted_licenses": "number",
  "licenses_expire": "date",
  "settings": "object",
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean",
    "manage": "boolean",
    "update_licenses": "boolean"
  }
}
Profile (ProfileTemplate)
JSON

{
  "id": "string",
  "public_profile_id": "string",
  "name": "string",
  "description": "string",
  "template": "boolean",
  "organization_id": "string",
  "communicator": "boolean",
  "settings": {
      "profile": "object"
  },
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean"
  }
}
Progress
JSON

{
  "id": "string",
  "status": "string",
  "message": "string",
  "percent": "number",
  "result_url": "string",
  "created_at": "date",
  "updated_at": "date"
}
Snapshot (LogSnapshot)
JSON

{
  "id": "string",
  "user_id": "string",
  "name": "string",
  "description": "string",
  "started_at": "date",
  "ended_at": "date",
  "data": "object",
  "permissions": {
      "view": "boolean",
      "edit": "boolean",
      "delete": "boolean"
  }
}
Sound (ButtonSound)
JSON

{
  "id": "string",
  "url": "string",
  "user_id": "string",
  "duration": "number",
  "content_type": "string",
  "name": "string",
  "permissions": {
      "view": "boolean",
      "edit": "boolean",
      "delete": "boolean"
  }
}
Tag (NFCTag)
JSON

{
  "id": "string",
  "tag_id": "string",
  "user_id": "string",
  "has_content": "boolean",
  "public": "boolean",
  "data": {
    "action": "string",
    "board_id": "string",
    "button_id": "string",
    "integration_id": "string",
    "label": "string"
  },
  "permissions": {
      "view": "boolean",
      "edit": "boolean",
      "delete": "boolean"
  }
}
Unit (OrganizationUnit)
JSON

{
  "id": "string",
  "organization_id": "string",
  "name": "string",
  "description": "string",
  "position": "number",
  "settings": "object",
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean",
    "view_stats": "boolean"
  }
}
User
JSON

{
  "id": "string",
  "user_name": "string",
  "name": "string",
  "email": "string",
  "avatar_url": "string",
  "created_at": "date",
  "expires_at": "date",
  "subscription": "object",
  "settings": "object",
  "permissions": "object"
}
Utterance
JSON

{
  "id": "string",
  "user_id": "string",
  "button_list": ["string"],
  "sentence": "string",
  "image_url": "string",
  "private": "boolean",
  "created_at": "date",
  "data": "object",
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean"
  }
}
Video (UserVideo)
JSON

{
  "id": "string",
  "url": "string",
  "user_id": "string",
  "duration": "number",
  "thumbnail_url": "string",
  "name": "string",
  "content_type": "string",
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean"
  }
}
Webhook
JSON

{
  "id": "string",
  "user_id": "string",
  "url": "string",
  "verifier": "string",
  "events": ["string"],
  "active": "boolean",
  "permissions": {
    "view": "boolean",
    "edit": "boolean",
    "delete": "boolean"
  }
}
Word (WordData - for admin use)
JSON

{
    "id": "string",
    "word": "string",
    "locale": "string",
    "part_of_speech": "string",
    "priority": "integer",
    "reviews": "integer",
    "skip": "boolean",
    "data": "object"
}
How to Use the API
Making Requests
All API requests should be made with the appropriate HTTP method (GET, POST, PUT, DELETE) to the endpoint URL. For endpoints that require authentication, include the API token in the headers as described in the "Authentication" section.

Pagination
List endpoints generally support pagination through the following query parameters:

per_page: Number of items per page (default typically 25, may vary).
page: Page number (default: 1).
Paginated responses usually include metadata within a meta key in the JSON response, with total counts and pagination information. Example:

JSON

{
  "users": [ /* ... user objects ... */ ],
  "meta": {
    "total_pages": 10,
    "total_count": 250,
    "current_page": 1,
    "per_page": 25
  }
}
Example Request (cURL)
Bash

curl -X GET "[https://your-lingolinq-domain.com/api/v1/users/self](https://your-lingolinq-domain.com/api/v1/users/self)" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
(Note: Replace https://your-lingolinq-domain.com with your actual API domain and YOUR_ACCESS_TOKEN with a valid token.)

Example User Response (for GET /api/v1/users/self)
JSON

{
  "user": {
    "id": "1_123",
    "user_name": "example",
    "name": "Example User",
    "avatar_url": "[https://example.com/avatar.png](https://example.com/avatar.png)",
    "settings": {
        "preferences": {
          "role": "communicator",
          "home_board": {
            "id": "1_456",
            "key": "example/home"
          }
          // ... other preferences
        }
        // ... other settings
    },
    "permissions": { // Permissions of the current API user towards 'self'
      "view_existence": true,
      "edit": true,
      "delete": true,
      "supervise": false
      // ... other permissions
    }
  }
}
Conclusion
This documentation covers the primary endpoints of the LingoLinq API v1. For additional help or information, please refer to application-specific guides or contact support.

