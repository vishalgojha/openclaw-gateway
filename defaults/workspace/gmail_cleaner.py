#!/usr/bin/env python3
"""
Gmail Storage Cleaner (IMAP) — no API key, no Google Cloud needed.

SETUP (one time):
  1. Enable 2-Step Verification:  https://myaccount.google.com/security
  2. Create an App Password:      https://myaccount.google.com/apppasswords
     -> choose "Other", generate, keep the 16-character code.
  3. Run this script and enter your Gmail address + app password when prompted
     (or export GMAIL_USER / GMAIL_APP_PASSWORD).

SAFETY:
  - DRY_RUN is True by default: prints counts, deletes nothing.
  - Starred messages always skipped when PROTECT_STARRED is True.
  - Old/large rules only touch All Mail minus Sent/Chats/Drafts.
  - "Delete forever" only happens because the script also purges the Trash
    folder (email in trash still counts against your 15GB).

Usage: python3 gmail_cleaner.py
"""

import getpass
import imaplib
import os
import time

IMAP_HOST = "imap.gmail.com"
IMAP_PORT = 993

FOLDER_ALL   = "[Gmail]/All Mail"
FOLDER_TRASH = "[Gmail]/Trash"
FOLDER_SPAM  = "[Gmail]/Spam"

CONFIG = {
    "USER": "",                        # leave "" to be prompted
    "APP_PASSWORD": "",                # leave "" to be prompted
    "DRY_RUN": True,                   # True = report only, False = actually delete
    "DELETE_SPAM": True,
    "DELETE_TRASH": True,
    "DELETE_OLDER_THAN_YEARS": 1,      # 0 disables
    "DELETE_LARGER_THAN_MB": 10,       # 0 disables
    "DELETE_CATEGORIES": ["promotions", "updates", "social", "forums"],
    "PROTECT_STARRED": True,
    "MAX_PER_RULE": 5000,
}


def connect():
    user = CONFIG["USER"] or os.environ.get("GMAIL_USER") or input("Gmail address: ").strip()
    pwd = CONFIG["APP_PASSWORD"] or os.environ.get("GMAIL_APP_PASSWORD")
    if not pwd:
        pwd = getpass.getpass("App password: ")
    conn = imaplib.IMAP4_SSL(IMAP_HOST, IMAP_PORT)
    conn.login(user, pwd)
    print(f"Connected: {user}\n")
    return conn


def search_uids(conn, folder, gmail_query):
    if CONFIG["DRY_RUN"]:
        conn.select(folder, readonly=True)
    else:
        conn.select(folder, readonly=False)
    if gmail_query == "ALL":
        typ, data = conn.uid("search", None, "ALL")
    else:
        typ, data = conn.uid("search", None, f'(X-GM-RAW "{gmail_query}")')
    if typ != "OK" or not data or not data[0]:
        return []
    uids = [u.decode() for u in data[0].split()]
    return uids[:CONFIG["MAX_PER_RULE"]]


def mark_deleted(conn, folder, uids):
    conn.select(folder, readonly=False)
    batch = list(uids)
    for chunk_start in range(0, len(batch), 200):
        chunk = batch[chunk_start:chunk_start + 200]
        conn.uid("store", ",".join(chunk), "+FLAGS", "(\\Deleted)")
        conn.expunge()
        time.sleep(0.2)


def purge_folder(conn, folder, name, action):
    uids = search_uids(conn, folder, "ALL")
    if not uids:
        print(f"[{name}] nothing there")
        return 0
    print(f"[{name}] {len(uids)} messages -> {action}")
    if not CONFIG["DRY_RUN"]:
        mark_deleted(conn, folder, uids)
    return len(uids)


def run_query(conn, query, action):
    uids = search_uids(conn, FOLDER_ALL, query)
    if not uids:
        print(f"[{query}] nothing found")
        return 0
    print(f"[{query}] {len(uids)} messages -> {action}")
    if not CONFIG["DRY_RUN"]:
        mark_deleted(conn, FOLDER_ALL, uids)
    return len(uids)


def main():
    conn = connect()
    report = {}

    if CONFIG["DELETE_SPAM"]:
        report["Spam"] = purge_folder(conn, FOLDER_SPAM, "Spam", "permanently deleted")

    if CONFIG["DELETE_TRASH"]:
        report["Trash"] = purge_folder(conn, FOLDER_TRASH, "Trash", "permanently deleted")

    if CONFIG["DELETE_OLDER_THAN_YEARS"] > 0:
        q = f"older_than:{CONFIG['DELETE_OLDER_THAN_YEARS']}y -in:sent -in:chats -in:drafts"
        if CONFIG["PROTECT_STARRED"]:
            q += " -is:starred"
        report[f"Older than {CONFIG['DELETE_OLDER_THAN_YEARS']}y"] = \
            run_query(conn, q, "trashed then purged")

    if CONFIG["DELETE_LARGER_THAN_MB"] > 0:
        q = f"has:attachment larger:{CONFIG['DELETE_LARGER_THAN_MB']}m -in:sent -in:chats -in:drafts"
        if CONFIG["PROTECT_STARRED"]:
            q += " -is:starred"
        report[f"Larger than {CONFIG['DELETE_LARGER_THAN_MB']}MB"] = \
            run_query(conn, q, "trashed then purged")

    for cat in CONFIG["DELETE_CATEGORIES"]:
        q = f"category:{cat}"
        if CONFIG["PROTECT_STARRED"]:
            q += " -is:starred"
        report[f"Category {cat}"] = run_query(conn, q, "trashed then purged")

    if not CONFIG["DRY_RUN"]:
        report["Final Trash purge"] = \
            purge_folder(conn, FOLDER_TRASH, "Final Trash purge", "permanently deleted")

    conn.logout()

    print("\n" + "=" * 50)
    mode = "DRY RUN (nothing deleted)" if CONFIG["DRY_RUN"] else "DELETE COMPLETE"
    print(f"Gmail cleanup: {mode}")
    total = 0
    for name, count in report.items():
        print(f"  - {name}: {count}")
        total += count
    print(f"  Total matched: {total}")
    print("=" * 50)
    if CONFIG["DRY_RUN"] and total:
        print("\nReview counts, then set CONFIG[\"DRY_RUN\"] = False and run again.")


if __name__ == "__main__":
    main()