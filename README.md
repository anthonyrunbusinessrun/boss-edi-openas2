# Legacy AS2 service - disabled

This repository no longer claims to implement OpenAS2.

DAAS GEX told Ray Land that the FEMA pathway can push only through ordinary
HTTPS on port 443. The active implementation therefore lives in
`boss-edi-connector` at `POST /edi/inbound`.

The previous service was a Node.js proxy that returned a successful AS2 MDN
without validating signatures, decrypting content, or proving downstream
processing. That behavior was unsafe and has been removed.

The deployed placeholder now returns `410 Gone` for `/as2`, reports `disabled`
at `/health`, and never accepts or forwards EDI payloads.

If a future trading partner requires AS2, build a separate, genuine OpenAS2
deployment with approved partner IDs, certificates, signing, encryption, MDN
validation, persistence, retry behavior, and conformance testing. Do not reuse
this placeholder as an AS2 implementation.

The historical insecure XML examples and forwarding script have been removed.
