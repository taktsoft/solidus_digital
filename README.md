# Solidus digital

Port [spree_digital](https://github.com/spree-contrib/spree_digital/) to [solidus](https://github.com/solidusio/solidus/).

For information on installation and use of this extension: see original `spree_digital` README!

NOTE: Forked after commit f1d74127a95805e25a1f4edeeba6cb520a3b9746 in `spree_digital`.

## TODOs

* [x] Fix admin digitals index partial (do not render `product_sub_menu` unnecessarily)
* [x] Improve digitals file path: use `private/system/digitals` considering standard Capistrano deployments
* [x] Only create digital_links once an order is complete! (i.e. once the order has passed the checkout process)
* [ ] First "release"

## Nice to have

* Fill missing specs (marked with `FIXME`), that were already missing in `spree_digital`
* Add specs for order confirmation mail including links?
* Translate `views/spree/admin/digitals/index.html.erb` and `views/spree/order_mailer/confirm_email.text.erb`
* Add more translations (e.g. German)
* Update `confirm_email` to `solidus` version 2.1.0's `confirm_email`
* Use button in `admin/orders` for resetting digital links, not an empty tab as just a link
* Verify user authentication and authorisation on download!
* Handle deprecation warnings
* Add specs for S3 storage of digital attachments
