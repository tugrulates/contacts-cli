"""MockAddressBook class."""


import json
from pathlib import Path
from typing import Iterator

from contacts.address_book import AddressBook
from contacts.contact import Contact
from tests.contact_diff import Mutation


class MockAddressBook(AddressBook):
    """Mock object for manipulation contacts."""

    def __init__(self, test_data_path: Path):
        """Initialize the mock."""
        self._test_data_path = test_data_path
        self._error = False
        self._data: dict[str, Contact] = {}
        self._updates: list[Mutation] = []
        self._adds: list[Mutation] = []
        self._deletes: list[Mutation] = []

    def error(self) -> None:
        """Raise an error upon invocation."""
        self._error = True

    def provide(self, *find_data: str) -> None:
        """Specify which test data to find in contacts."""
        contacts = [
            Contact(
                **json.loads(
                    Path(self._test_data_path / x)
                    .with_suffix(".json")
                    .read_text(encoding="utf-8")
                )
            )
            for x in find_data
        ]
        self._data = {x.contact_id: x for x in contacts}

    def count(self, _: list[str]) -> int:
        """Return number of contacts matching given keywords."""
        if self._error:
            raise RuntimeError(1, "count")
        return len(self._data)

    def find(self, _: list[str]) -> Iterator[Contact]:
        """Return list of contact ids matching given keywords."""
        if self._error:
            raise RuntimeError(1, "find")
        yield from self._data.values()

    def get(self, contact_id: str) -> Contact:
        """Fetch a contact with its id."""
        if self._error:
            raise RuntimeError(1, "get")
        return self._data[contact_id]

    def update_field(self, contact_id: str, field: str, value: str) -> None:
        """Update a contact field with given value."""
        self._updates.append((contact_id, field, value))

    def delete_field(self, contact_id: str, field: str) -> None:
        """Delete a contact field."""
        self._deletes.append((contact_id, field))

    def update_info(
        self, contact_id: str, field: str, info_id: str, label: str, value: str
    ) -> None:
        """Update a contact info with given label and value."""
        self._updates.append((contact_id, field, info_id, label, value))

    def add_info(self, contact_id: str, field: str, label: str, value: str) -> None:
        """Add a contact info."""
        self._adds.append((contact_id, field, label, value))

    def delete_info(self, contact_id: str, field: str, info_id: str) -> None:
        """Delete a contact info."""
        self._deletes.append((contact_id, field, info_id))
