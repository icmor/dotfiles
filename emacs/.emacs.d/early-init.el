;;; -*- lexical-binding: t -*-
;;; Frame Configuration
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;;; No splash screens
(setq inhibit-startup-screen t)
(setq inhibit-startup-buffer-menu t)

;;; Speed-up startup
(setq gc-cons-threshold most-positive-fixnum) ; will be reverted by gmch-mode
(setq default-gc-percentage 0.8)
