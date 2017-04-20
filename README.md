# Solidus digital

Port [spree_digital](https://github.com/spree-contrib/spree_digital/) to [solidus](https://github.com/solidusio/solidus/).

For information on installation and use of this extension: see original spree_digital README!

NOTE: Forked after commit f1d74127a95805e25a1f4edeeba6cb520a3b9746 in `spree_digital`.

## TODOs

* [x] Fix admin digitals index partial (do not render `product_sub_menu` unnecessarily)
* [ ] Improve digitals file path (use `private/system/digitals`)
* [ ] Fill missing specs (marked with `FIXME`)
* [ ] Translate `views/spree/admin/digitals/index.html.erb` and `views/spree/order_mailer/confirm_email.text.erb`
* [ ] First "release"

## Nice to have

* Add more translations (e.g. German)
* Use button in `admin/orders` for resetting digital links, not an empty tab as just a link
* Verify user authentication and authorisation on download!
