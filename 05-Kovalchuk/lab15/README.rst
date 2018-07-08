==================
Lab 15. WEB-Server
==================

This lab uses `Vagga`_ containers for its implementation. Please note, that
vagga cannot be run as root, thus this solution without much modifications will
only apply to those who do not need to access privileged ports (1 - 1024)


Running
=======

In order to run this lab you will need to generate certificates first. To do
so, invoke ``vagga gen-cert`` command, which will create root certificate and
domain certificates in ``cert`` directory.

Secondly, you may want to add ``cert/anxolerdCA.pem`` certificate as trusted in
your browser.

Create host mapping from ``beta.zone05.net`` and ``srv-05.zone05.net`` to your
machine. As an easy solution you may add this entry to your ``/etc/hosts``
file:

.. code-block::

   127.0.0.1    beta.zone05.net srv-05.zone05.net

Finally, run nginx server within container using ``vagga run`` and visit
https://beta.zone05.net and https://srv-05.zone05.net

.. _`Vagga`: https://vagga.readthedocs.io
