# Solidus digital

Port of [spree_digital](https://github.com/spree-contrib/spree_digital/) to [solidus](https://github.com/solidusio/solidus/).

* Solidus version >= 2.0.0 for Rails 5 compatibility.
* NOTE: Order confirmation emails need to be customised to include download links. This version of the gem overrides the whole text confirmation_email, but is not completely translated. So for now, if you want to include download links in the confirmation email and use the plain text emails, you may have to override that yourself. If you want to include download links in a HTML confirmation email, you have to set that up yourself.
* For more information on installation and use of this extension: see original `spree_digital` README!
* Forked after commit f1d74127a95805e25a1f4edeeba6cb520a3b9746 in `spree_digital`.

## Changes

### solidus_digital, version 1.0.0

* Port of `spree_digital` to Solidus, so that `solidus_digital` can be installed in a Rails 5 app with Solidus 2.1.0
* Fix admin digitals index partial (do not render `product_sub_menu` unnecessarily)
* Improve digitals file path: use `private/system/digitals` considering standard Capistrano deployments
* Only create digital_links once an order is complete! (i.e. once the order has passed the checkout process)

## Nice to have

* Fill missing specs (marked with `FIXME`), that were already missing in `spree_digital`
* Add specs for order confirmation mail including links?
* Add more translations (e.g. German)
* Translate `views/spree/admin/digitals/index.html.erb` and `views/spree/order_mailer/confirm_email.text.erb`
* Update `confirm_email` to `solidus` version 2.1.0's `confirm_email`
* Do not override whole `confirm_email`, rather use Deface to hook into `confirm_email` to add download links and information on downloads
* Use button in `admin/orders` for resetting digital links, not an empty tab as just a link
* Verify user authentication and authorisation on download!
* Handle deprecation warnings
* Add specs for S3 storage of digital attachments
