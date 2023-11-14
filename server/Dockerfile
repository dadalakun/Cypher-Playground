FROM golang:1.21 as builder

# Copy the code and compile it
WORKDIR /app

# Copy the go.mod and go.sum files first to download Go module dependencies
COPY go.mod go.sum ./
RUN go mod download

COPY . .
# Compile the Go server
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o goserver main.go

FROM scratch
# Copy the binary from the builder stage
COPY --from=builder /app/goserver /goserver

EXPOSE 8080

ENTRYPOINT ["/goserver"]