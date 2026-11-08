# VIBRA Music Radar

People near you who share your musical taste, designed so nobody's
location can be learned from it. Server: migration
`20261110000000_music_radar.sql`. App: `/music-radar`, opened from the
Social tab. Privacy guarantees are pinned by
`test/core/music_radar_privacy_test.dart`.

## 1. What it shows

* **Compatible people nearby:** affinity ≥ 45 within the chosen radius,
  with an exact count.
* **The sound of your area:** the average genre-family share of nearby
  people's Musical DNA, top 5. Shown only when at least 5 people
  contribute.
* **Compatible profiles:** the same card as Same Frequency (Send Vibra,
  Message when allowed, Save, Discover shared artists). People already
  connected have no Send Vibra.
* **Upcoming events for your sound:** events within the radius in the next
  45 days, ranked by:
  * one of your artists;
  * an artist you share with people nearby;
  * one of your genre families;
  * a genre that's popular in the area.

  Genre matching is coarse: Ticketmaster labels are compared with family
  names.
* **Communities for your area's sound:** up to 3 communities you haven't
  joined, matching the area's top genre families. This is computed in the
  app from the area aggregate, so it adds no location data.

## 2. Privacy model

| Threat | Defence |
|---|---|
| Reading someone's coordinates | Exact location stays on the private `users` row. Radar positions live in `vibra_private.radar_presence`, which the API cannot reach. `get_music_radar` returns no coordinates, distances, cells or timestamps. |
| Inferring distance from order | People are ordered by affinity, then a daily per-viewer hash, never by distance |
| Narrowing someone down by probing (moving your own point, trying radii) | Everyone is placed at the **centre of a grid cell**: about 5 km ("area") or about 20 km ("region"), their choice. Probing can reveal at most the cell. Radii are fixed (5/10/25/50 km). Queries are rate-limited (6/min). |
| Following live movements | A radar position (anchor) moves **at most once every 6 hours**. Locations older than 14 days drop out. |
| Re-identifying people through area statistics | Area genre stats need ≥ 5 contributors and are averages |
| Being found without wanting to be | Off by default (`radar_enabled`). It requires the existing location consent. **Hide** (`radar_visible = false`) lets you look without appearing. Blocks and test segments apply (`may_access_message`). |

* **Turning it off.** Switching off the radar or the location consent,
  deleting privacy preferences, or deleting the account removes the radar
  position at once. Triggers handle this.
* **Precision changes.** Changing precision re-snaps the *same* anchor,
  so it cannot be used to skip the 6-hour rule.
* **Data export.** The personal data export includes your own radar cell
  centre and its timestamps.

## 3. Settings (`set_music_radar_settings`)

| Setting | Values | Default |
|---|---|---|
| Music Radar | on / off | off |
| Show me on the radar | on / off | on |
| Discovery distance | 5 / 10 / 25 / 50 km | 25 km |
| Location precision | area (~5 km) / region (~20 km) | area |

Location itself is still controlled by Privacy controls → location. The
radar uses the private server location that the app already sends (with
consent) for Live and nearby features. Turning the radar on refreshes it.

## 4. Known limits

* A person's cell can, by design, be learned by someone determined. That
  is the precision they chose (about 5 or 20 km).
* Event genre matching is approximate. The server-side catalogue
  classifier (TypeScript) is not available to SQL.
