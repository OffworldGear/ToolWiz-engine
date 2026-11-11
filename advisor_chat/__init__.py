"""Advisor Chat: a conversational assistant next to Fusion that works through the Setup Advisor with the owner.

ToolWiz stays the source of every number: the model only reaches ToolWiz through ``advisor_chat.tools`` and every reply is
checked by ``toolwiz_common.numeric_guard`` against the tool results of the conversation. See docs/ADVISOR_CHAT.md.
"""
