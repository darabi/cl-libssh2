;;; -*- mode: lisp; syntax: common-lisp; indent-tabs-mode: nil -*-

(in-package :libssh2.test)

(in-suite integration)

(deftest sftp-copy-back-and-forth ()
  (with-testfile.tgz
    ;; let's be sure we have no file left over from previous tests
    (sftp-delete sshc "/tmp/renamed-with-sftp.tgz")
    (scp-put test-file remote-name)
    (is (some (lambda (f) (equal "copied-to-remote.tgz" f)) (sftp-list-directory sshc "/tmp" :maxfiles 10 :extensions '(".tgz"))))
    ;; copy back from ssh host using sftp
    (sftp-get sshc remote-name final)
    ;; calculate remote md5
    (verify-remote-md5 sshc remote-name md5)
    (sftp-rename sshc remote-name "/tmp/renamed-with-sftp.tgz")
    (is (some (lambda (f) (equal "renamed-with-sftp.tgz" f)) (sftp-list-directory sshc "/tmp" :maxfiles 10 :extensions '(".tgz"))))
    (sftp-delete sshc "/tmp/renamed-with-sftp.tgz")
    (is (not (some (lambda (f) (equal "renamed-with-sftp.tgz" f)) (sftp-list-directory sshc "/tmp" :maxfiles 10 :extensions '(".tgz")))))))

(deftest sftp-delete-existing ()
  (with-testfile.tgz
    ;; copy to remote
    (scp-put test-file remote-name)
    ;; delete the remote file
    (is (eq 0 (sftp-delete sshc remote-name)))))

(deftest sftp-delete-missing ()
  (with-testfile.tgz
    ;; delete an non-existing remote file with ignore-missing set to NIL
    (signals ssh-generic-error (sftp-delete sshc "non-existing-file-1328" :ignore-missing nil))))
