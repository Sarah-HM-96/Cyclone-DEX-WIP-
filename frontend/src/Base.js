const Base = (props) => {
    const { children } = props;

    return (
        <div className="min-w-screen min-h-screen text-gray front-arial" style ={{ backgroundColor: '#111111' }}>
            {children}
        </div>
    );
};

export default Base;