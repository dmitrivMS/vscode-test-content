================
Getting Started
================

Installation
============

Install the package using pip:

.. code-block:: bash

   pip install mypackage

Configuration
=============

Create a configuration file at ``~/.mypackage/config.yaml``:

.. code-block:: yaml

   database:
     host: localhost
     port: 5432
   logging:
     level: INFO

Usage Example
=============

.. code-block:: python

   from mypackage import Client

   client = Client.from_config()
   results = client.query("SELECT * FROM users LIMIT 10")

   for row in results:
       print(row["name"], row["email"])

.. note::

   Ensure the database is running before executing queries.

See :doc:`api-reference` for full documentation.
