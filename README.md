# Ice Scoop’s

Mobile-first ice cream ordering with plain HTML, CSS and JavaScript, an Express API, and a persistent SQLite database. The shop starts with all 15 flavours from the brief. The original logo is stored in `public/assets/logo.png`. The sundae and flavour images were generated from studio-photography prompts and can be replaced with outlet photography from Menu Management.

## Run locally

On the Windows workspace where the project was built, double-click `Start Ice Scoops.cmd` to use the portable runtime. On another machine, install Node.js 24 LTS, then run these commands from the project folder.

```sh
npm ci
npm start
```

Open [the storefront](http://localhost:3100) or [the staff portal](http://localhost:3100/admin.html). The backend creates the SQLite file, tables, and menu seed on first start. Counter checkout works immediately. Create a staff account to manage orders.

### Add staff

Use a unique password of at least 12 characters. The command reads it from standard input or the temporary `ICE_STAFF_PASSWORD` environment variable. Do not put staff passwords in the source files or the permanent `.env`.

PowerShell example:

```powershell
if (Test-Path '.tools\node-v24.22.3-win-x64\node.exe') {
  $env:Path = (Resolve-Path '.tools\node-v24.22.3-win-x64').Path + ';' + $env:Path
}
$env:ICE_STAFF_PASSWORD = Read-Host -MaskInput 'New staff password'
npm.cmd run staff -- owner owner
Remove-Item Env:ICE_STAFF_PASSWORD
```

`owner` can manage the menu, kitchen, payments and reports. `staff` can manage orders, payments and reports. `kitchen` can see released kitchen tickets and advance preparation statuses. Running the command again for an existing username replaces its password and role and closes its existing sessions.

## Configure Razorpay

1. Copy `.env.example` to `.env`, then set `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET` and a separate `RAZORPAY_WEBHOOK_SECRET`. Use Razorpay Test Mode first.
2. Enable automatic capture in the Razorpay dashboard. In the same mode, subscribe to `payment.captured` at your HTTPS origin plus `/api/webhooks/razorpay`. Configure the matching webhook secret.
3. Place test-mode orders and exercise a successful capture, a declined payment, a dismissed checkout and a delayed webhook. Confirm the order and KOT appear only after capture. Move to live keys and a live-mode webhook after these checks.

The server creates the Razorpay order using its own total in paise. It verifies the checkout signature with the stored gateway order ID, checks capture and amount, and verifies webhook signatures against the raw body. An online order awaiting capture stays out of the staff queue. Online payment is disabled when credentials are absent. The automated tests verify the signed webhook path locally. A Razorpay account and a reachable HTTPS webhook are needed for gateway testing.

[Razorpay Standard Checkout](https://razorpay.com/docs/payments/payment-gateway/web-integration/standard/integration-steps) · [Webhook verification](https://razorpay.com/docs/webhooks/validate-test)

## Deploy

1. Copy the project to a host that supports a long-running Node.js 24 process and a persistent disk. Install with `npm ci --omit=dev`. Use one application instance with SQLite on local persistent storage.
2. Set `NODE_ENV=production`, `PUBLIC_ORIGIN` to the exact HTTPS storefront origin, and `DATABASE_PATH` to a path on the persistent volume. Set `HOST` and `PORT` to the app bind address and upstream port for your deployment. Run `npm start` under a process supervisor and create the owner account using the production database configuration.
3. Put the application behind an HTTPS reverse proxy with buffering disabled for `/api/staff/events`, and a read timeout of at least 60 seconds. Forward the original scheme. Set `TRUST_PROXY_HOPS=1` for one direct trusted proxy when direct access to Node is blocked. Adjust this value only to match a known fixed proxy path.
4. Keep routine backups of the SQLite database using a SQLite-aware backup method or a stopped application and consistent database snapshot. Keep configuration and signing secrets in protected environment variables. Test storefront, checkout and staff access at the production URL before printing ordering QR codes.

SQLite stores orders, catalog changes, product uploads, tickets, staff sessions and audit records on the same persistent volume. Node inserts order snapshots and advances the daily counter in one transaction. Day boundaries use Asia/Kolkata. Catalog updates affect future orders. For a multi-instance deployment, move storage and event delivery to shared services before scaling horizontally.

## Outlet setup

- **Counter payments.** Pending counter orders appear live in the staff portal. Confirm payment to release their KOT. Set `COUNTER_RELEASE_KOT_IMMEDIATELY=true` if your kitchen prepares orders before collecting payment.
- **Thermal printing.** Select 58 mm or 80 mm in the Orders view and choose **Print KOT**. In the operating system or browser print dialog, select the matching thermal paper, 100% scale, and turn off browser headers and footers. Print one sample before service. Staff can reprint the existing ticket from order history.
- **Receipts.** Customers can print or download a self-contained HTML receipt. The staff portal can reprint orders and export daily sales to CSV.
- **Ordering QR.** In the staff portal, open **Ordering QR** and download or print a storefront code. Enter a table label to prefill it for Dine-In. Set `PUBLIC_ORIGIN` to the shop’s HTTPS URL before printing kiosk or table codes.

Run `npm test` to verify the pricing, order IDs, matching cones, duplicate checkout protection, staff permissions, live events, kitchen workflow and signed payment webhooks. The schema is in `server/schema.sql` and the seed is in `server/catalog.js`.

## Website images

The supplied logo is unchanged. The built-in ImageGen tool produced the hero at `public/assets/sundae.jpg` and the original menu set at `public/assets/products/1.jpg` through `15.jpg`.

<details>
<summary>ImageGen prompts</summary>

**Flavour photos**

> Create ONE premium studio food photography contact sheet for a website ice cream menu, in a perfect 4-column by 4-row grid of 16 equal square cells. No gaps, no outlines, no text, no typography, no labels. Each cell is an independent packshot with nearly identical warm pale peach studio background (#f8e6d8). The scoop and its garnishes NEVER cross cell boundaries and have generous padding inside each square. Each photographed subject is centered, a single large beautifully textured round ice cream scoop on pale matte peach seamless sweep, 3/4 view, low shadow, a few photoreal ingredients beside it (no bowl or cone). Consistent warm editorial studio lighting, professional macro detail and styling. Exact order left to right: ROW 1 vanilla off-white and vanilla pod; pink strawberry and two strawberries; orange Alphonso mango and mango cubes; beige mawa almond with toasted almonds. ROW 2 buttery caramel butterscotch with golden crunchy balls; pale ice cream with chocolate chips; rich brown chocolate brownie with brownie cubes; deep purple black currant with blackcurrant berries. ROW 3 pearly tender coconut with coconut pieces; bright pink chilli guava with guava wedge and red chilli; pale cream American nuts and jelly with nuts and bright candied jelly; Belgium chocolate with pecans and chocolate pieces. ROW 4 dark chocolate mud cake with cake crumbs; lilac blueberry cheesecake with blueberries and biscuit crumbs; pale green pista malai with pistachios; honey waffle cone packshot. True grid with strictly equal square cells and consistent scale, neatly centered artwork. Commercial food photography, real edible ingredients and color, no decorative graphics.

**Hero photo**

> Wide editorial food photograph, landscape aspect ratio 3:2, for a boutique Indian ice cream shop website hero. Beautiful real textured golden Alphonso mango ice cream, vanilla cream and pale pistachio scoop in a small vintage fluted glass dessert bowl. The ice cream bowl is the large centerpiece, occupying about 75 percent of image height, all its edges in frame, centered just right of center. On a solid warm pale peach (#ffe8d0) matte seamless studio background with no horizon, directed afternoon sun from upper left and elegant soft shadows. On the lower right of the scene two small diced mango pieces and pistachios. Photorealistic fine ice cream textures, spoon-scooped curls, tiny nut garnish, golden creamy tones, carefully art directed with clean negative space and bright orange undertones. No lettering, no logos, no typography, no additional dish, no people. Designed to crop in both landscape and slightly-taller close up.

</details>

