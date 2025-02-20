## REST API

Hitobito offers a read-only JSON REST API that gives access to the basic data stored in the database. The output format follows the conventions of [json:api](http://jsonapi.org) (although in an older version according to this issue https://github.com/hitobito/hitobito/issues/207).

### Authentication

To use the API you need a valid authentication token, this can be one of the following

* Service tokens
* Personal OAuth access tokens
* Personal API tokens **(deprecated)**

#### Service token

Service tokens are impersonal tokens ([service accounts](07_service_accounts.md)), that are meant to represent external applications.

> :bangbang: Service tokens allow you to implement user unaware applications. Note that the
consumer application is responsible for data protection: with service tokens the application
may be able to access data which is not intended for public access!

#### Personal OAuth access token

Personal OAuth access tokens have the same permissions as the corresponding user, this allows you
to implement an application where users log in using Hitobito as an OAuth authentication provider.

To use the API, the provided access token is required to have the `api` scope, see [OAuth](08_oauth.md) for more information.

#### Personal API token

> :bangbang: As of September 2021, personal API tokens are **deprecated**. This way of accessing the API will be removed in the future. Please don't create any new client applications using this means of API access. Any third-party applications using personal API tokens will need to migrate to OAuth access tokens. These cover the same use-cases but are much more secure: the user doesn't have to give their hitobito password to the third-party application, and the tokens have a limited lifespan.

The documentation for personal API tokens has been removed from here, because they should not be used anymore. If you still need to refer to that documentation, you can read the old version of the docs [here](https://github.com/hitobito/hitobito/blob/68bb038977bdc5ff22b8110e482becb9396aede3/doc/development/05_rest_api.md).

### Endpoints

Currently the following endpoints are provided:

| Method | Path                                              | Function                                                                        |
| ---    | ---                                               | ---                                                                             |
| GET    | /groups/:id                                       | Group details                                                                   |
| GET    | /groups/:id/people                                | People of a certain group                                                       |
| GET    | /groups/:group_id/people/:id                      | Person details                                                                  |
| GET    | /groups/:group_id/events                          | Events of a certain group                                                       |
| GET    | /groups/:group_id/events/:id                      | Event details                                                                   |
| GET    | /groups/:group_id/events/:id/participations       | Participations of certain event                                                 |
| GET    | /groups/:group_id/events/:id/participations/:id   | Participation details                                                           |
| GET    | /groups/:group_id/events/course                   | Courses of a certain group                                                      |
| GET    | /groups/:group_id/invoices                        | Invoices of a certain group                                                     |
| GET    | /groups/:group_id/invoices/:id                    | Invoice details                                                                 |
| GET    | /groups/:group_id/mailing_lists/:id               | Mailing list details and subscribers (actual people subscribed to the list)     |
| GET    | /groups/:group_id/mailing_lists/:id/subscriptions | Details on the groups / roles, events and single people which are subscribed    |



#### Events endpoint

The events and the course endpoints have some query parameters, as explained below.

| Name       | Type     | Description                                                          | Default               | Available Values                           | Example                 |
| ---        | ---      | ---                                                                  | ---                   | ---                                        | ---                     |
| type       | `string` | Specify class type                                                   | Nil (normal event)    | `Event::Course` and wagon specific classes | `type=Event::Course`    |
| filter     | `string` | Specify whether to only display events from the current layer | `all`                 | `all`, `layer`                             | `filter=layer`          |
| start_date | `date`   | Filter events ending after or at start_date                   | Today                 | Any date                                   | `start_date=31-10-2018` |
| end_date   | `date`   | Filter events starting before or at end_date                  | Nil (upcoming events) | Any date                                   | `end_date=28-02-2019`   |

An example query with its response (formatted here for readability) can be seen below.

```bash
curl "https://demo.hitobito.com/groups/1/events.json?token=yhFrXcydFwisXYLEUFyV&filter=layer"
```

```json
{
  "events": [
    {
      "id": "1",
      "type": "events",
      "name": "LK 102",
      "description": "Aut exercitationem quia. Sed vel optio. Veritatis deserunt in consequuntur excepturi. Tenetur in dolores veniam vero quas dolor.",
      "motto": "Laboriosam amet id hic quo saepe et corrupti repellendus.",
      "cost": "",
      "maximum_participants": 38,
      "participant_count": 0,
      "location": "Ankerweg 7\r\n84377\r\nHannahscheid",
      "application_opening_at": "2017-10-28",
      "application_closing_at": "2019-02-03",
      "application_conditions": "",
      "state": "",
      "teamer_count": 6,
      "external_application_link": "http://demo.hitobito.com/de/groups/1/public_events/1",
      "links": {
        "kind": "1",
        "dates": [
          "1"
        ],
        "groups": [
          "1"
        ]
      }
    }
  ],
  "linked": {
    "event_kinds": [
      {
        "id": "1",
        "label": "Leitungskurs",
        "short_name": "LK",
        "minimum_age": null,
        "general_information": null,
        "application_conditions": null
      }
    ],
    "event_dates": [
      {
        "id": "1",
        "label": "Kurs",
        "start_at": "2018-02-02T00:00:00.000+01:00",
        "finish_at": "2018-02-10T00:00:00.000+01:00",
        "location": ""
      }
    ],
    "groups": [
      {
        "id": "1",
        "href": "http://demo.hitobito.com/de/groups/1.json",
        "group_type": "Hauptebene",
        "layer": true,
        "name": "Dachverband",
        "short_name": "Dachverband",
        "email": "alta.haley@example.org",
        "address": "Schellingstr. 8",
        "zip_code": 5692,
        "town": "Damianburg",
        "country": null,
        "created_at": "2018-11-08T14:39:36.000+01:00",
        "updated_at": "2018-11-08T14:39:36.000+01:00",
        "deleted_at": null,
        "links": {
          "layer_group": "1",
          "hierarchies": [
            "1"
          ],
          "children": [
            "3",
            "4",
            "5",
            "6",
            "16",
            "11",
            "2"
          ]
        }
      },
      {
        "id": "1",
        "name": "Dachverband",
        "group_type": "Hauptebene"
      },
      {
        "id": "3",
        "name": "Geschäftsstelle",
        "group_type": "Geschäftsstelle"
      },
      {
        "id": "4",
        "name": "Kontakte",
        "group_type": "Kontakte"
      },
      {
        "id": "5",
        "name": "Mitglieder",
        "group_type": "Mitglieder"
      },
      {
        "id": "6",
        "name": "Region Bern",
        "group_type": "Region/Kanton"
      },
      {
        "id": "16",
        "name": "Region Nordost",
        "group_type": "Region/Kanton"
      },
      {
        "id": "11",
        "name": "Region Zürich",
        "group_type": "Region/Kanton"
      },
      {
        "id": "2",
        "name": "Vorstand",
        "group_type": "Vorstand"
      }
    ]
  },
  "links": {
    "groups.creator": {
      "href": "http://demo.hitobito.com/de/people/{groups.creator}.json",
      "type": "people"
    },
    "groups.updater": {
      "href": "http://demo.hitobito.com/de/people/{groups.updater}.json",
      "type": "people"
    },
    "groups.deleter": {
      "href": "http://demo.hitobito.com/de/people/{groups.deleter}.json",
      "type": "people"
    },
    "groups.parent": {
      "href": "http://demo.hitobito.com/de/groups/{groups.parent}.json",
      "type": "groups"
    },
    "groups.layer_group": {
      "href": "http://demo.hitobito.com/de/groups/{groups.layer_group}.json",
      "type": "groups"
    },
    "groups.hierarchy": {
      "href": "http://demo.hitobito.com/de/groups/{groups.hierarchy}.json",
      "type": "groups"
    },
    "groups.children": {
      "href": "http://demo.hitobito.com/de/groups/{groups.children}.json",
      "type": "groups"
    },
    "groups.people": {
      "href": "http://demo.hitobito.com/de/groups/{groups.id}/people.json",
      "type": "people"
    }
  }
}
```


#### Event Participations endpoint

The participations associated with a single evnt


An example query with its response (formatted here for readability) can be seen below.

```bash
curl "https://demo.hitobito.com/groups/1/events/1/participations.json?token=yhFrXcydFwisXYLEUFyV&filter=layer"
```

```json
{
  "current_page": 1,
  "total_pages": 1,
  "next_page_link": null,
  "prev_page_link": null,
  "event_participations": [
    {
      "id": "127527",
      "type": "event_participations",
      "first_name": "Thomas",
      "last_name": "Schüpbach",
      "nickname": "Ipsam",
      "company_name": null,
      "company": false,
      "email": "schuepbach.thomas@hotmail.com",
      "address": "Gluckstr. 2",
      "zip_code": "7185",
      "town": "Nord Judy",
      "country": null,
      "gender": "m",
      "birthday": "1974-05-17",
      "picture": {
        "picture": {
          "url": "/assets/profil-3a8452c9ac8e8b1b70b9d4f4250417bea5be8a4518dbfae44db944f8fda07ca5.png",
          "thumb": {
            "url": "/assets/profil_thumb-0296a3526d1e1cb1a5a9c63fbe5c913977bc1d1361f8bccb23259dda216aa9e8.png"
          }
        }
      },
      "primary_group_id": 18,
      "roles": [
        {
          "type": "Event::Role::Leader",
          "name": "Leitung"
        }
      ],
      "links": {
        "person": "3086"
      },
      "additional_information": "",
      "active": true,
      "qualified": null,
      "payed": true
    },
    {
      "id": "127525",
      "type": "event_participations",
      "first_name": "Thomas",
      "last_name": "Test II",
      "nickname": "Toast",
      "company_name": null,
      "company": false,
      "email": "thomas2@mail.com",
      "address": "Gluckstr. 4",
      "zip_code": "7185",
      "town": "Nord Judy",
      "country": null,
      "gender": "m",
      "birthday": "2000-12-31",
      "picture": {
        "picture": {
          "url": "/assets/profil-3a8452c9ac8e8b1b70b9d4f4250417bea5be8a4518dbfae44db944f8fda07ca5.png",
          "thumb": {
            "url": "/assets/profil_thumb-0296a3526d1e1cb1a5a9c63fbe5c913977bc1d1361f8bccb23259dda216aa9e8.png"
          }
        }
      },
      "primary_group_id": 1,
      "roles": [
        {
          "type": "Event::Role::Leader",
          "name": "Leitung"
        }
      ],
      "links": {
        "person": "3103"
      },
      "additional_information": "",
      "active": true,
      "qualified": null,
      "payed": true
    },
    {
      "id": "127524",
      "type": "event_participations",
      "first_name": "Thomas",
      "last_name": "Test III",
      "nickname": "Toast",
      "company_name": null,
      "company": false,
      "email": "thomas3@mail.ch",
      "address": "Gluckstr. 4",
      "zip_code": "7185",
      "town": "Nord Judy",
      "country": null,
      "gender": "m",
      "birthday": "2000-12-31",
      "picture": {
        "picture": {
          "url": "/assets/profil-3a8452c9ac8e8b1b70b9d4f4250417bea5be8a4518dbfae44db944f8fda07ca5.png",
          "thumb": {
            "url": "/assets/profil_thumb-0296a3526d1e1cb1a5a9c63fbe5c913977bc1d1361f8bccb23259dda216aa9e8.png"
          }
        }
      },
      "primary_group_id": 33,
      "roles": [
        {
          "type": "Event::Role::Participant",
          "name": "Teilnehmer"
        }
      ],
      "links": {
        "person": "3105"
      },
      "additional_information": "",
      "active": true,
      "qualified": null,
      "payed": false
    }
  ],
  "linked": {},
  "links": {
    "event_participations.person": {
      "href": "https://cevi.puzzle.ch/people/{event_participations.person}.json",
      "type": "people"
    }
  }
}
```


#### Invoices endpoint

The invoices have query parameters similar to ui, the list endpoint is paged.

| Name      | Type     | Description              | Available Values                                            |
| ---       | ---      | ---                      | ---                                                         |
| q         | `string` | Seach string             |                                                             |
| state     | `string` | Invoice state            | `draft`, `issued`, `sent`, `payed`, `reminded`, `cancelled` |
| due_since | `string` | Overdue invoices by time | `one_day`, `one_week`, `one_month`                          |
| year      | `number` | Filter by issue year     |                                                             |


An example query with its response (formatted here for readability) can be seen below.

```bash
curl "https://demo.hitobito.com/groups/1/invoices.json?token=yhFrXcydFwisXYLEUFyV&filter=layer"
```

```json
{
  "invoices": [
    {
      "id": "1",
      "type": "invoices",
      "title": "Pens",
      "sequence_number": "1-1",
      "state": "draft",
      "esr_number": "00 00000 00000 10000 00000 00018",
      "description": "",
      "recipient_email": "dummy@example.com",
      "recipient_address": "",
      "sent_at": null,
      "due_at": null,
      "total": "11.00 CHF",
      "created_at": "2019-12-05T16:06:09.000+01:00",
      "updated_at": "2019-12-05T16:06:09.000+01:00",
      "account_number": "01-162-5",
      "address": "",
      "issued_at": null,
      "iban": "CH93 0076 2011 6238 5295 7",
      "payment_purpose": null,
      "payment_information": "",
      "beneficiary": "",
      "payee": "asdf",
      "participant_number": "",
      "vat_number": "",
      "links": {
        "creator": "221",
        "group": "1",
        "invoice_items": [
          "1"
        ]
      }
    }
  ],
  "linked": {
    "groups": [
      {
        "id": "1",
        "name": "Dachverband",
        "group_type": "Hauptebene"
      }
    ],
    "invoice_items": [
      {
        "id": "1",
        "name": "Pen",
        "description": "Handy when writing",
        "vat_rate": "10.0",
        "unit_cost": "1.0",
        "count": 10,
        "cost_center": "Office",
        "account": "101"
      }
    ]
  },
  "links": {
    "invoices.creator": {
      "href": "http://localhost:3000/de/people/{invoices.creator}.json",
      "type": "people"
    },
    "invoices.recipient": {
      "href": "http://localhost:3000/de/people/{invoices.recipient}.json",
      "type": "people"
    }
  }
}
```
