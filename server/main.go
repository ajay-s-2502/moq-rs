package main

import (
	"context"
	"crypto/sha256"
	"crypto/tls"
	"encoding/hex"
	"flag"
	"fmt"
	"log"

	"github.com/kixelated/invoker"
	"github.com/kixelated/warp/server/internal/warp"
	"github.com/kixelated/warp/server/internal/web"
)

func main() {
	err := run(context.Background())
	if err != nil {
		log.Fatal(err)
	}
}

func run(ctx context.Context) (err error) {
	addr := flag.String("addr", ":4443", "HTTPS server address")
	cert := flag.String("tls-cert", "../cert/localhost.crt", "TLS certificate file path")
	key := flag.String("tls-key", "../cert/localhost.key", "TLS certificate file path")
	logDir := flag.String("log-dir", "", "logs will be written to the provided directory")

	dash := flag.String("dash", "../media/playlist.mpd", "DASH playlist path")

	flag.Parse()

	media, err := warp.NewMedia(*dash)
	if err != nil {
		return fmt.Errorf("failed to open media: %w", err)
	}

	tlsCert, err := tls.LoadX509KeyPair(*cert, *key)
	if err != nil {
		return fmt.Errorf("failed to load TLS certificate: %w", err)
	}

	warpConfig := warp.Config{
		Addr:   *addr,
		Cert:   &tlsCert,
		LogDir: *logDir,
		Media:  media,
	}

	warpServer, err := warp.New(warpConfig)
	if err != nil {
		return fmt.Errorf("failed to create warp server: %w", err)
	}

	hash := sha256.Sum256(tlsCert.Certificate[0])
	fingerprint := hex.EncodeToString(hash[:])

	webConfig := web.Config{
		Addr:        *addr,
		CertFile:    *cert,
		KeyFile:     *key,
		Fingerprint: fingerprint,
	}

	webServer := web.New(webConfig)

	log.Printf("listening on %s", *addr)

	return invoker.Run(ctx, invoker.Interrupt, warpServer.Run, webServer.Run)
}
